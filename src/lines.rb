#
# Methods related to the lines.
#



module BM
  class Lines


    # When the action is to cull a line, main calls this.
    def cull_lines
      self.read_lines!

      if self.lines.empty?
        ret = self.why_no_lines?
      else
        self.get_wanted_line!
        if self.line.nil?
          ret = self.out_msg(:valnah)
        else
          self.chop_val!
          if self.val.nil?
            ret = self.out_msg(:valno)
          else
            ret = self.sysact.call
          end
        end
      end

      return ret
    end



    # Reads the file.
    # Filters lines from the file that match the @args.
    # Fills in the @lines array.
    def read_lines!(filts = self.args)
      ret = [ ]

      if self.has_file and !self.nil_file
        filts = (filts.empty?) ? [ ] : self.args_to_filts
        fh = File.open(self.file_path, 'r')
        while line = fh.gets(BM.line_sep)
          line = line.chomp(BM.line_sep).strip
          ret.push(line) if self.does_line_match?(line, filts)
        end
        fh.close
      end

      self.lines = ret
      self.sort_lines! if (!ret.empty?)
    end



    def sort_lines!
      hsh = { }
      self.lines.each do |line|
        p = self.line_to_parts(line)
        hsh[p[:val]] = line
      end

      ks, arr = hsh.keys.sort, [ ]
      ks.each { |k| arr.push(hsh[k]) }
      self.lines = arr
    end



    def print_lines
      n, x = 1, self.lines.count.to_s.length

      self.lines.each do |line|
        parts = self.line_to_parts(line)
        y = x - n.to_s.length
        spc = (y > 0) ? (' ' * y) : ''
        pre = "#{spc}#{n})"
        puts "#{pre} #{self.clean(parts[:val])}"
        if !parts[:tags].empty?
          spc = ' ' * (pre.length)
          puts "#{spc} Tags: #{self.clean(parts[:tags].join(', '))}"
        end
        n += 1
      end
    end



    def prompt_for_line(inc0 = true)
      c = (self.lines.count.to_s.length - 1)
      spc = (c > 0) ? (' ' * c) : ''
      puts "#{spc}0) None." if inc0
      print "#{spc}?: "

      x = STDIN.gets.chomp().gsub(/[^0-9]+/, '').to_i
      if (x == 0)
        ret = nil
      elsif (x <= self.lines.count)
        ret = self.lines[(x - 1)]
      else
        puts "Bad choice. Try again."
        ret = self.prompt_for_line(nil)
      end

      return ret
    end



    def write_lines
      ret = nil

      if self.has_file
        fh, n, m = File.open(self.file_path, 'w'), 0, self.lines.length
        self.lines.each do |line|
          fh.puts line
          n += 1
          fh.puts BM.line_sep if (n < m)
        end
        fh.close
        self.check_file!
        ret = self.has_file
      end

      return ret
    end



    def remove_line_from_lines!
      self.lines.delete self.line
    end



    # Provides a reason why there are no lines.
    # Mostly here because the same block would be used in multiple methods.
    def why_no_lines?
      if self.has_file
        if self.nil_file
          ret = self.out_msg(:fileempty)
        elsif self.args.empty?
          ret = self.out_msg(:linesno)
        else
          ret = self.out_msg(:matchno)
        end
      else
        ret = self.out_msg(:fileno)
      end

      return ret
    end


  end
end
