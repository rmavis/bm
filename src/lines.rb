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

      if self.hub.store.has_file && !self.hub.store.nil_file
        filts = (args.empty?) ? [ ] : self.clean_args(args)
        incluv = self.hub.filter_inclusive?

        fh = File.open(self.hub.store.file, 'r')

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
        m_arr.push(line.mar)
        l_arr.push(line)
      end

      m_arr, out = m_arr.sort, [ ]
      m_arr.each do |mar|
        l_arr.each do |line|
          if line.mar == mar
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
        if (self.pool.count == 1) && (!self.delmode)
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



    def print!( io = $stdout, newline = nil )
      x = self.pool.count.to_s.length
      n = 1

      self.pool.each do |line|
        y = x - n.to_s.length
        spc = (y > 0) ? (' ' * y) : ''
        pre = "#{spc}#{n})"

        io.puts("#{pre} #{Star::Utils.clean(line.val.str)}")  # #{line.mar}

        if line.val.title.is_a?(String)
          spc = ' ' * (pre.length)
          io.puts("#{spc} Title: #{Star::Utils.clean(line.val.title)}")
        end

        if !line.tags.pool.empty?
          spc = ' ' * (pre.length)
          io.puts("#{spc} Tags: #{Star::Utils.clean(line.tags.pool.join(', '))}")
          io.puts "" if newline
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

      if x.is_a?(Array)
        bads = [ ]

        x.each do |n|
          chk = self.get_line_by_number(n)

          if chk.is_a?(Star::Line)
            ret.push(chk)
          else
            bads.push(n)
          end
        end

        if !bads.empty?
          if x.length == 1

            if (x[0] == 0) || (x[0].nil?)
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
      if (n > 0) && (n <= self.pool.count)
        ret = self.pool[(n - 1)]
      else
        ret = nil
      end

      return ret
    end



    def act_on_selection
      save = true

      if self.hub.act == :delete
        self.selection.each { |line| line.del = true }

      elsif ((self.hub.act == :copy) ||
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
      sav_file = self.hub.store.file
      tmp_file = self.hub.store.make_backup_file(Star::Fileutils.temp_ext, nil)

      sav_f = File.open(sav_file, 'r')
      tmp_f = File.open(tmp_file, 'w')

      selections = self.selection.clone

      while l_str = sav_f.gets(Star::Utils.grp_sep)
        l_obj = Star::Line.new(l_str)

        if !l_obj.blank?
          # This doesn't chomp the group separator.
          out_s = l_str.strip.chomp

          if !selections.empty?
            catch(:out) do
              selections.each do |sel_l|
                if ((l_obj.val.str == sel_l.val.str) &&
                    (l_obj.val.title == sel_l.val.title) &&
                    (l_obj.tags.pool == sel_l.tags.pool))
                  # puts "Comparing #{sel_l.val.str} to #{l_obj.val.str}?"
                  if sel_l.del
                    puts Star::Message.out(:delok,
                                           Star::Utils.clean(sel_l.val.str))
                    out_s = nil

                  else
                    if sel_l.val.swap_str && sel_l.tags.swap
                      out_s = sel_l.to_s(true, true)
                    else
                      out_s = sel_l.to_s(true)
                    end
                  end

                  selections.delete(sel_l)
                  throw(:out)
                end
              end
            end
          end

          # So no group separator needs to be appended here.
          tmp_f.puts(out_s) if !out_s.nil?
        end
      end

      if !selections.empty?
        selections.each do |sel_l|
          tmp_f.puts(sel_l.to_s(true))
          puts Star::Message.out(:saveok, sel_l.val.str)
        end
      end

      sav_f.close
      tmp_f.close

      File.rename(tmp_file, sav_file)
    end



    def why_none?
      if self.hub.store.has_file
        if self.hub.store.nil_file
          ret = Star::Message.out(:fileempty, self.hub.store.file)
        elsif self.hub.args.empty?
          ret = Star::Message.out(:linesno, self.hub.store.file)
        else
          ret = Star::Message.out(:matchno)
        end

      else
        ret = Star::Message.out(:fileno, self.hub.store.file)
      end

      return ret
    end



    def is_delmode?
      if (self.hub.act == :delete) then true else nil end
    end



    def clean_args( args = self.hub.args )
      # They are escaped because they are stored escaped.
      # And check if it's a string because, if a label is present,
      # it will be a hash.
      args.collect! { |f| Star::Utils.escape(f).downcase if f.is_a?(String) }
      return args.uniq
    end



    def edit
      # puts "Starting edit"
      self.read!

      if self.pool.empty?
        # puts self.why_none?

      else
        # puts "Pool has #{self.pool.length} entries."
        # - get tmp file
        tmp_name = Star::Fileutils.fx_file
        tmp_file = File.new(tmp_name, 'w', 0600)

        if File.exists?(tmp_name)
          # puts "Writing message to temp file #{tmp_name}"
          # - write to tmp file & close
          if self.hub.config.edit_head?
            tmp_file.puts(Star::Message.edit_file_instructions)
          end
          # puts "Writing pool to temp file"
          self.print!(tmp_file, self.hub.config.edit_space?)
          tmp_file.close

          # - wait while edit
          # puts "Opening temp file in editor"
          check = system(ENV['EDITOR'], tmp_name)

          if check
            # - read tmp file
            # puts "Reading temp file"
            # - replace lines in pool
            # puts "Updating pool from edits"
            self.selection = self.collate_edits(self.read_edit_file(tmp_file))
            # - write to store
            # puts "Saving updates to store"
            self.save_to_store

          else
            # puts "Editor returned badly"
          end

        else
          # puts "Temporary edit file does not exist"
        end

        # - delete tmp file
        # puts "Deleting temp file #{tmp_name}"
        File.delete(tmp_name)
      end
    end



    def read_edit_file( file )
      entries, entry, pair_up = [ ], nil, nil

      lines = File.open(file, 'r')

      lines.each do |line|
        if parts = line.match(/\A[ \t]*([0-9]+)\)[ \t]+(.+)\Z/)
          check = parts[2].strip

          if !check.empty?
            entry = Star::Line.edit_line_parts
            entry[:index] = (parts[1].to_i.abs - 1)
            entry[:value] = check
            pair_up = true
          end

        elsif parts = line.match(/\A[ \t]*(?:Tags:[ \t]*)(.+)\Z/)
          if pair_up && entry.is_a?(Hash)
            entry[:tags] = parts[1].split(',').sort.collect { |t| t.strip }
          end

        elsif parts = line.match(/\A[ \t]*(?:Title:[ \t]*)(.+)\Z/)
          if pair_up && entry.is_a?(Hash)
            entry[:title] = parts[1].strip
          end
        end

        if pair_up &&
           entry.is_a?(Hash) &&
           entry[:index].is_a?(Integer) &&
           entry[:value].is_a?(String) &&
           entry[:tags].is_a?(Array)
          entries.push(entry)
          pair_up = nil
        end
      end

      lines.close

      return entries
    end



    def collate_edits( edits )
      ret = self.pool.clone

      ids = [ ]
      edits.each { |edit| ids.push(edit[:index]) }
# puts "Edited indices: #{ids.to_s}"

      # This must happen before the next block because the pool
      # could change size there.
# puts "Pool contains #{ret.length} entries"
      (0...ret.length).each do |n|
# puts "Checking on pool index #{n}"
        if !ids.include?(n)
# puts "ID pool does not include #{n}"
          ret[n].del = true
          # puts "Marking for deletion #{n}: #{ret[n].val.str}"
        else
# puts "ID pool contains #{n}"
        end
      end

      edits.each do |edit|
        if ret[edit[:index]]
          ret[edit[:index]].val.swap_str = edit[:value]
# puts "Setting value swap: #{ret[edit[:index]].val.swap_str}"
          ret[edit[:index]].val.swap_title = edit[:title] if edit.has_key?(:title)
# puts "Setting title swap: #{ret[edit[:index]].val.swap_title}"
          ret[edit[:index]].tags.swap = edit[:tags]
# puts "Setting tags swap: #{ret[edit[:index]].tags.swap}"
        # metadata?

        else
# puts "Creating new line with value: #{edit[:value]}"
          line = Star::Line.new
          if edit.has_key?(:title)
            line.fill_from_array(edit[:tags] + [edit[:value]] + [{:title => edit[:title]}])
          else
            line.fill_from_array(edit[:tags] + [edit[:value]])
          end
          ret.push(line)
        end
      end

      return ret
    end


  end
end
