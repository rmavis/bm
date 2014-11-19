#
# Methods related to the line.
#



module Bm
  class Line < Bm::Hub


    def initialize( str = '' )
      @val, @tags, @meta = Bm::Value.new, Bm::Tags.new, Bm::Metadata.new

      if str.is_a? String
        @str = str
        self.from_s
      else
        @str = nil
      end
    end

    attr_accessor :str, :val, :tags, :meta



    def blank?
      if (self.str.is_a? String) then nil else true end
    end



    def from_s
      arr = self.str.split(Bm::Utils.rec_sep)

      if arr.is_a? Array
        if arr.length == 3
          self.val.str = arr[0].strip
          self.tags.from_s(arr[1])
          self.meta.from_s(arr[2])

        else  # Anything?
          self.str = nil
        end

      else
        self.str = nil
      end
    end



    def to_s
      str =
        self.val.str + Bm::Utils.grp_sep +
        self.tags.to_s + Bm::Utils.grp_sep +
        self.meta.to_s + Bm::Utils.rec_sep
    end



    def matches?( filts = [ ], incluv = nil )
      ret = nil

      if !self.val.str.empty?
        if filts.empty?
          ret = true

        else
          if incluv
            goodlim, loose = 1, true
          else
            goodlim, loose = filts.length, nil
          end

          good = 0

          filts.each do |filt|
            if self.tags.pool.empty?
              good += 1 if self.val.downcase.include? filt

            else
              self.tags.pool.each do |tag|
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



    # When the action is to create a new line, main calls this.
    def new_line
      if self.args.empty?
        ret = Bm::Message.out(:argsno)

      else
        ret = (self.has_file) ? "\n" : self.init_file
        self.line_from_args!
        self.chop_val!

        if self.write_line
          ret <<
            "\n" + Bm::Message.out(:saveok) +
            "\n" + self.sysact.call
        else
          ret << "\n" + Bm::Message.out(:savefail)
        end

        ret = ret.strip
      end

      return ret
    end



    # When the action is to delete a line, main calls this.
    def delete_line
      self.lines.read!

      if self.lines.empty?
        ret = self.lines.why_none?
      else
        self.get_wanted_line!
        if self.line.nil?
          ret = Bm::Message.out(:delnah)
        else
          self.chop_val!
          self.lines.read!([ ])  # Reads the whole file.
          self.remove_line_from_lines!
          self.make_backup_file!
          if self.write_lines
            self.delete_backup_file!
            ret = Bm::Message.out(:delok, self.clean(self.val))
          else
            ret = Bm::Message.out(:delfail, true)
          end
        end
      end

      return ret
    end



    def write_line
      ret = nil

      if self.has_file
        fh = File.open(self.store.file_path, 'a+')
        if self.nil_file
          fh.puts self.line
        else
          fh.puts Bm::Utils.rec_sep + "\n" + self.line
        end
        fh.close
        self.check_file!
        ret = self.has_file
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
          ret = tags.join(Bm.unit_sep) + Bm.unit_sep + val
        end
        ret = Bm::Utils.escape(ret)
      end

      self.line = ret
    end


  end
end
