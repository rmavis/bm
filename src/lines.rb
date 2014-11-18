#
# Methods related to the lines.
#


module BM
  class Lines < BM::BM


    def initialize
      @pool, @selection = [ ], [ ]
    end

    attr_accessor :pool, :selection



    # When the action is to cull a line, main calls this.
    def cull
      self.read!

      if self.pool.empty?
        ret = self.why_none?

      else
        # After this, self.selection will be nil or an array.
        self.get_wanted_line   #HERE

        if self.selection.nil?
          ret = BM::Message.out(:valnah)
        else
          self.selection.each do |line|
            if line.val.nil?
              ret = BM::Message.out(:valno, line.string)
            else
              ret = self.sysact.call(line)
            end
          end
        end
      end

      return ret
    end




    # Reads the file.
    # Filters lines from the file that match the @args.
    # Fills in the @lines array.

    def read!( args = self.args )
      self.pool = [ ]

      if self.store.has_file and !self.store.nil_file
        filts = (args.empty?) ? [ ] : self.clean_args(args)
        incluv = BM::Utils.filter_inclusive?

        fh = File.open(self.store.file_path, 'r')
        while l_str = fh.gets(BM::Utils.group_sep)
          l_obj = BM::Line.new(l_str)
          self.pool.push(l_obj) if l_obj.matches?(filts, incluv)
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

      ks, arr = hsh.keys.sort, [ ]
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
        puts "#{pre} #{BM::Utils.clean(line.val)}"
        if !line.tags.empty?
          spc = ' ' * (pre.length)
          puts "#{spc} Tags: #{BM::Utils.clean(line.tags.join(', '))}"
        end
        n += 1
      end
    end



    def prompt_for_line( inc0 = true )
      c = (self.pool.count.to_s.length - 1)
      spc = (c > 0) ? (' ' * c) : ''
      puts "#{spc}0) None." if inc0
      print "#{spc}?: "

      x = BM::Args.parse_lines_prompt(STDIN.gets.chomp)

      if x.is_a? Array
        ret, bads = [ ], [ ]

        x.each do |n|
          chk = self.get_line_by_number(n)

          if chk.is_a? BM::Line
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
            puts "Skipping entries #{bads.join(', ')."
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



    def write_lines
      ret = nil

      if self.has_file
        fh, n, m = File.open(self.file_path, 'w'), 0, self.pool.length
        self.pool.each do |line|
          fh.puts line
          n += 1
          fh.puts BM::Utils.rec_sep if (n < m)
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
      if self.store.has_file
        if self.store.nil_file
          ret = BM::Message.out(:fileempty)
        elsif self.args.empty?
          ret = BM::Message.out(:linesno)
        else
          ret = BM::Message.out(:matchno)
        end
      else
        ret = BM::Message.out(:fileno)
      end

      return ret
    end



    def clean_args( args = self.args )
      # They are escaped because they are stored escaped.
      args.collect! { |f| BM::Utils.escape(f).downcase }
      return args.uniq
    end


  end
end
