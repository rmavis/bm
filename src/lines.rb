#
# Methods related to the lines.
#


module Bm
  class Lines < Bm::Hub


    def initialize( hub )
      if hub.is_a? Bm::Hub
        @hub, @pool, @selection = hub, [ ], [ ]

      else
        raise Exception.new("Can't instantiate new Lines: need a Hub.")
      end
    end

    attr_reader :hub
    attr_accessor :pool, :selection



    # When the action is to cull a line, main calls this.
    def cull
      self.read!

      if self.pool.empty?
        ret = self.why_none?

      else
        # After this, ::selection will be nil or an array.
        self.get_wanted_line

        if self.selection.nil?
          ret = Bm::Message.out(:valnah)

        else
          self.selection.each do |line|

            if line.val.nil?
              puts Bm::Message.out(:valno, line.string)
            else
              self.sysact.call(line.val)
              self.touch_and_record
            end

          end
        end

      end
    end




    # Reads the file.
    # Filters lines from the file that match the @args.
    # Fills in the @lines array.

    def read!( args = self.hub.args )
      self.pool = [ ]

      if self.hub.store.has_file and !self.hub.store.nil_file
        filts = (args.empty?) ? [ ] : self.clean_args(args)
        incluv = Bm::Utils.filter_inclusive?

        fh = File.open(self.hub.store.file_path, 'r')
        while l_str = fh.gets(Bm::Utils.grp_sep)
          l_obj = Bm::Line.new(l_str)
          if !l_obj.blank?
            self.pool.push(l_obj) if l_obj.matches?(filts, incluv)
          end
        end
        fh.close
      end

      self.sort!
    end



    # This functionality #HERE will need to be updated.
    # The lines should be able to sort on value or metadata.
    def sort!
      hsh = { }
      self.pool.each do |line|
        hsh[line.val] = line
      end

      ks, arr = hsh.keys.sort, [ ]  #HERE
      ks.each { |k| arr.push(hsh[k]) }
      self.pool = arr
    end



    def get_wanted_line
      if self.pool.empty?
        self.selection = nil

      else
        # If only one line matches, skip the browsing step.
        if self.pool.count == 1   # (self.act == :filt)
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
        puts "#{pre} #{Bm::Utils.clean(line.val.str)}"
        if !line.tags.pool.empty?
          spc = ' ' * (pre.length)
          puts "#{spc} Tags: #{Bm::Utils.clean(line.tags.pool.join(', '))}"
        end
        n += 1
      end
    end



    def prompt_for_line( inc0 = true )
      c = (self.pool.count.to_s.length - 1)
      spc = (c > 0) ? (' ' * c) : ''
      puts "#{spc}0) None." if inc0
      print "#{spc}?: "

      x = Bm::Args.parse_lines_prompt(STDIN.gets.chomp)

      if x.is_a? Array
        ret, bads = [ ], [ ]

        x.each do |n|
          chk = self.get_line_by_number(n)

          if chk.is_a? Bm::Line
            ret.push chk
          else
            bads.push n
          end
        end

        if !bads.empty?
          if x.length == 1
            if x == 0
              ret = nil
            else
              puts "Bad choice. Try again."
              ret = self.prompt_for_line(nil)
            end
          else
            puts "Skipping entries #{bads.join(', ')}."
          end
        end

        ret = nil if ret.empty?

      else  # This will only happen if x isn't a String.
        ret = nil
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




    def touch_and_record
      self.selection.each { |l| l.meta.touch }

      sav_file = self.hub.store.file_path
      tmp_file = Bm::Store.backup_file_path(Bm::Store.temp_ext)

      sav_f = File.open(sav_file, 'r')
      tmp_f = File.open(tmp_file, 'w')

      while l_str = sav_f.gets(Bm::Utils.grp_sep)
        out_s = l_str

        l_obj = Bm::Line.new(l_str)
        self.selection.each do |sel_l|
          if ((l_obj.val.str == sel_l.val.str) and
              (l_obj.tags.pool == sel_l.tags.pool))
            out_s = sel_l.to_s
          end
        end

        tmp_f.puts out_s + Bm::Utils.grp_sep
      end

      sav_f.close
      tmp_f.close

      File.delete(tmp_file) if File.rename(tmp_file, sav_file)
    end



    def write_lines
      ret = nil

      if self.has_file
        fh, n, m = File.open(self.file_path, 'w'), 0, self.pool.length
        self.pool.each do |line|
          fh.puts line
          n += 1
          fh.puts Bm::Utils.rec_sep if (n < m)
        end
        fh.close
        self.check_file!
        ret = self.has_file
      end

      return ret
    end



    def remove_line_from_lines!
      self.pool.delete self.selection
    end



    # Provides a reason why there are no lines.
    # Mostly here because the same block would be used in multiple methods.
    def why_none?
      if self.hub.store.has_file
        if self.hub.store.nil_file
          ret = Bm::Message.out(:fileempty)
        elsif self.hub.args.empty?
          ret = Bm::Message.out(:linesno)
        else
          ret = Bm::Message.out(:matchno)
        end
      else
        ret = Bm::Message.out(:fileno)
      end

      return ret
    end



    def clean_args( args = self.hub.args )
      # They are escaped because they are stored escaped.
      args.collect! { |f| Bm::Utils.escape(f).downcase }
      return args.uniq
    end


  end
end
