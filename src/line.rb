#
# Methods related to the line.
#



module BM
  class Line < BM::BM


    def self.parts_h
      {
        :val => '',
        :tags => [ ],
        :data => BM::Metadata._h
      }
    end



    def self.to_parts( str = '' )
      ret = BM::Line.parts_h

      arr = str.split(BM::Utils.rec_sep)

      ret[:val] = arr[0]
      ret[:tags] = BM::Tags.to_a(arr[1])
      ret[:data] = BM::Metadata.to_h(arr[2])

      return ret
    end




    def initialize( str = '' )
      @str, @val, @tags, @data = nil, nil, [ ], { }

      if str.is_a? String
        @str = str
        self.to_parts
      end
    end

    attr_accessor :str, :val, :tags, :data



    def to_parts
      p = BM::Line.to_parts(self.str)
      self.val = p[:val]
      self.tags = p[:tags]
      self.data = p[:data]
    end



    def matches?( filts = [ ], incluv = nil )
      ret = nil

      if !self.val.empty?
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
            if self.tags.empty?
              good += 1 if self.val.downcase.include? filt

            else
              self.tags.each do |tag|
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
        ret = BM::Message.out(:argsno)

      else
        ret = (self.has_file) ? "\n" : self.init_file
        self.line_from_args!
        self.chop_val!

        if self.write_line
          ret <<
            "\n" + BM::Message.out(:saveok) +
            "\n" + self.sysact.call
        else
          ret << "\n" + BM::Message.out(:savefail)
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
          ret = BM::Message.out(:delnah)
        else
          self.chop_val!
          self.lines.read!([ ])  # Reads the whole file.
          self.remove_line_from_lines!
          self.make_backup_file!
          if self.write_lines
            self.delete_backup_file!
            ret = BM::Message.out(:delok, self.clean(self.val))
          else
            ret = BM::Message.out(:delfail, true)
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
          fh.puts BM::Utils.rec_sep + "\n" + self.line
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
          ret = tags.join(BM.unit_sep) + BM.unit_sep + val
        end
        ret = BM::Utils.escape(ret)
      end

      self.line = ret
    end


  end
end
