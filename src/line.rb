#
# Methods related to the line.
#


module Star
  class Line


    def self.new_from_args( hub )
      if hub.is_a? Star::Hub

        line = Star::Line.new hub
        line.fill_from_args

        if hub.store.append? line
          puts Star::Message.out :saveok
        else
          puts Star::Message.out :savefail
        end

      else
        raise Exception.new("Can't create new STAR Line: need a Hub.")
      end
    end




    def initialize( ini = nil )
      @val, @tags, @meta = Star::Value.new, Star::Tags.new, Star::Metadata.new
      @str, @hub = nil, nil

      if ini.is_a? String
        @str = ini
        self.from_s
      elsif ini.is_a? Star::Hub
        @hub = ini
      end
    end

    attr_reader :hub
    attr_accessor :str, :val, :tags, :meta



    def blank?
      if (self.str.is_a? String) then nil else true end
    end



    def to_s( add_sep = nil )
      str =
        self.val.str + Star::Utils.rec_sep +
        self.tags.to_s + Star::Utils.rec_sep +
        self.meta.to_s

      str << Star::Utils.grp_sep if add_sep

      return str
    end



    def from_s
      arr = self.str.split Star::Utils.rec_sep

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


    def fill_from_args
      if self.hub.args.is_a? Array
        self.val.str = self.hub.args.pop.strip
        self.tags.pool = self.hub.args
        self.meta.ini

      else
        # Should an error go #HERE?
      end
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


  end
end
