#
# Methods related to the lines.
#


module Star
  class Lines < Star::Hub


    def initialize( hub )
      if hub.is_a? Star::Hub
        @hub, @pool, @selection = hub, [ ], [ ]
        @delmode = self.is_delmode?

      else
        raise Exception.new("Can't instantiate STAR Lines: need a Hub.")
      end
    end

    attr_reader :hub
    attr_accessor :pool, :selection, :delmode



    def cull
      self.read!

      if self.pool.empty?
        puts self.why_none?

      else
        self.get_wanted_line

        if self.selection.empty?
          puts Star::Message.out(:valnah, self.hub.act)
        else
          self.act_on_selection
        end

      end
    end



    def read!( args = self.hub.args )
      self.pool = [ ]

      if self.hub.store.has_file and !self.hub.store.nil_file
        filts = (args.empty?) ? [ ] : self.clean_args(args)
        incluv = self.hub.filter_inclusive?

        fh = File.open(self.hub.store.file_path, 'r')
        while l_str = fh.gets(Star::Utils.grp_sep)
          l_obj = Star::Line.new(l_str)
          if !l_obj.blank?
            self.pool.push(l_obj) if l_obj.matches?(filts, incluv)
          end
        end
        fh.close
      end

      self.sort!
    end



    # This sorts by the line's Match Accuracy Rating.
    def sort!
      l_arr, m_arr = [ ], [ ]
      self.pool.each do |line|
        m_arr.push(line.adj_mar)
        l_arr.push(line)
      end

      m_arr, out = m_arr.sort, [ ]
      m_arr.each do |mar|
        l_arr.each do |line|
          if line.adj_mar == mar
            out.push(line)
            l_arr.delete(line)
          end
        end
      end

      self.pool = out.reverse
    end



    def get_wanted_line
      if self.pool.empty?
        self.selection = [ ]

      else
        # If only one line matches, skip the browsing step.
        if (self.pool.count == 1) and (!self.delmode)
          self.selection = [self.pool[0]]
        else
          self.selection = self.which_line?
        end
      end
    end



    def which_line?
      self.print!
      ret = self.prompt_for_line
      return ret
    end



    def print!
      n, x = 1, self.pool.count.to_s.length

      self.pool.each do |line|
        y = x - n.to_s.length
        spc = (y > 0) ? (' ' * y) : ''
        pre = "#{spc}#{n})"
        puts "#{pre} #{Star::Utils.clean(line.val.str)} (#{line.adj_mar})"  # 
        if !line.tags.pool.empty?
          spc = ' ' * (pre.length)
          puts "#{spc} Tags: #{Star::Utils.clean(line.tags.pool.join(', '))}"
        end
        n += 1
      end
    end



    def prompt_for_line( inc0 = true )
      ret = [ ]

      c = (self.pool.count.to_s.length - 1)
      spc = (c > 0) ? (' ' * c) : ''
      puts "#{spc}0) None." if inc0
      print "#{spc}?: "

      x = Star::Args.parse_lines_prompt(STDIN.gets.chomp)

      if x.is_a? Array
        bads = [ ]

        x.each do |n|
          chk = self.get_line_by_number(n)

          if chk.is_a? Star::Line
            ret.push chk
          else
            bads.push n
          end
        end

        if !bads.empty?
          if x.length == 1

            if (x[0] == 0) or (x[0].nil?)
              ret = [ ]
            else
              puts "Bad choice. Try again."
              ret = self.prompt_for_line(nil)
            end

          else
            puts "Skipping entries #{bads.join(', ')}."
          end
        end
      end

      return ret
    end



    def get_line_by_number( n = 0 )
      if (n > 0) and (n <= self.pool.count)
        ret = self.pool[(n - 1)]
      else
        ret = nil
      end

      return ret
    end



    def act_on_selection
      save = true

      if self.hub.act == :delete
        self.delmode = true

      elsif ((self.hub.act == :copy) or
             (self.hub.act == :open))
        self.selection.each do |line|
          line.meta.touch
          if self.hub.act == :copy
            line.val.copy
          else
            line.val.open
          end
        end

      else
        save = nil
        puts Star::Message.out(:actbad)
      end

      self.save_to_store if save
    end



    def save_to_store
      sav_file = self.hub.store.file_path
      tmp_file = self.hub.store.make_backup_file(Star::Store.temp_ext, nil)

      sav_f = File.open(sav_file, 'r')
      tmp_f = File.open(tmp_file, 'w')

      while l_str = sav_f.gets(Star::Utils.grp_sep)
        l_obj = Star::Line.new(l_str)

        if !l_obj.blank?
          # This doesn't chomp the group separator.
          out_s = l_str.strip.chomp

          self.selection.each do |sel_l|
            if ((l_obj.val.str == sel_l.val.str) and
                (l_obj.tags.pool == sel_l.tags.pool))
              if self.delmode
                puts Star::Message.out(:delok, Star::Utils.clean(sel_l.val.str))
                out_s = nil

              else
                # A true to to_s will append a group separator.
                out_s = sel_l.to_s(true)
              end
            end
          end

          # So no group separator needs to be appended here.
          tmp_f.puts out_s if !out_s.nil?
        end
      end

      sav_f.close
      tmp_f.close

      File.rename(tmp_file, sav_file)
    end



    def why_none?
      if self.hub.store.has_file
        if self.hub.store.nil_file
          ret = Star::Message.out(:fileempty, self.hub.store.name)
        elsif self.hub.args.empty?
          ret = Star::Message.out(:linesno, self.hub.store.name)
        else
          ret = Star::Message.out(:matchno)
        end

      else
        ret = Star::Message.out(:fileno, self.hub.store.name)
      end

      return ret
    end



    def is_delmode?
      if (self.hub.act == :delete) then true else nil end
    end



    def clean_args( args = self.hub.args )
      # They are escaped because they are stored escaped.
      args.collect! { |f| Star::Utils.escape(f).downcase }
      return args.uniq
    end


  end
end
