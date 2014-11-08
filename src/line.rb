#
# Methods related to the line.
#



module BM
  class Line


    # When the action is to create a new line, main calls this.
    def new_line
      if self.args.empty?
        ret = self.out_msg(:argsno)

      else
        ret = (self.has_file) ? "\n" : self.init_file
        self.line_from_args!
        self.chop_val!

        if self.write_line
          ret <<
            "\n" + self.out_msg(:saveok) +
            "\n" + self.sysact.call
        else
          ret << "\n" + self.out_msg(:savefail)
        end

        ret = ret.strip
      end

      return ret
    end



    # When the action is to delete a line, main calls this.
    def delete_line
      self.read_lines!

      if self.lines.empty?
        ret = self.why_no_lines?
      else
        self.get_wanted_line!
        if self.line.nil?
          ret = self.out_msg(:delnah)
        else
          self.chop_val!
          self.read_lines!([ ])  # Reads the whole file.
          self.remove_line_from_lines!
          self.make_backup_file!
          if self.write_lines
            self.delete_backup_file!
            ret = self.out_msg(:delok, self.clean(self.val))
          else
            ret = self.out_msg(:delfail, true)
          end
        end
      end

      return ret
    end



    def write_line
      ret = nil

      if self.has_file
        fh = File.open(self.file_path, 'a+')
        if self.nil_file
          fh.puts self.line
        else
          fh.puts BM.line_sep + "\n" + self.line
        end
        fh.close
        self.check_file!
        ret = self.has_file
      end

      return ret
    end



    def get_wanted_line!
      if self.lines.empty?
        self.line = nil
      else
        # If only one line matches, skip the browsing step.
        if self.lines.count == 1   # (self.act == :filt)
          self.line = self.lines[0]
        else
          self.line = self.which_line?
        end
      end
    end



    def which_line?
      self.print_lines
      ret = self.prompt_for_line
      return ret
    end



    def does_line_match?(line = self.line, filts = self.args)
      ret = nil

      if !line.empty?
        if filts.empty?
          ret = true

        else
          if self.inclusive?
            goodlim, loose = 1, true
          else
            goodlim, loose = filts.length, nil
          end
          p, good = self.line_to_parts(line), 0

          filts.each do |filt|
            if p[:tags].empty?
              good += 1 if p[:val].downcase.include? filt
            else
              p[:tags].each do |tag|
                if loose
                  good += 1 if tag.include? filt
                else
                  good += 1 if tag.downcase == filt
                end
              end
            end
          end
          ret = true if good >= goodlim
        end
      end

      return ret
    end



    def line_from_args!(arr = self.args)
      ret = nil

      if arr.is_a? Array
        val = arr.pop
        if arr.empty?
          ret = val
        else
          tags = arr.sort
          ret = tags.join(BM.tag_sep) + BM.tag_sep + val
        end
        ret = self.escape(ret)
      end

      self.line = ret
    end



    def line_to_parts(str = self.line)
      ret = { :val => '', :tags => [ ] }

      arr = str.split(BM.tag_sep)
      ret[:val] = arr.pop
      ret[:tags] = arr.sort.collect { |t| t.strip } if !arr.empty?

      return ret
    end



    def escape(str = self.line)
      ret = str
      BM.escapes.each do |esc|
        ret = ret.gsub(esc){ "\\#{esc}" }
      end

      return ret
    end


    def clean(str = self.line)
      ret = str
      BM.escapes.each do |esc|
        ret = ret.gsub("\\#{esc}"){ esc }
      end

      return ret
    end


  end
end
