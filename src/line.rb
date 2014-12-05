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
      @str, @hub, @mars = nil, nil, [ ]

      if ini.is_a? String
        @str = ini
        self.from_s
      elsif ini.is_a? Star::Hub
        @hub = ini
      end
    end

    attr_reader :hub
    attr_accessor :str, :val, :tags, :meta, :mars



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



    # So searching "cohen" doesn't return a value tagged "leonard cohen"
    # because the tag-match is only partial. So maybe there should be
    # multiple grades of matches. Exact matches have the highest grade,
    # and the returns are displayed and the array is ordered according
    # to those grades.

    def matches?( filts = [ ], incluv = nil )
      ret = nil

      if !self.val.str.empty?
        if filts.empty?
          ret = true

        else
          goodlim = (incluv) ? 1 : filts.length
          good = 0

          filts.each do |filt|
            regex = '.*'
            filt.downcase.each_char { |c| regex << c+'.*' }
            tagmatch = nil

            if self.val.str.downcase.match(regex)
              mar = filt.length.to_f / self.val.str.length.to_f
              self.adj_mar(mar)
              tagmatch = true
            end

            if !self.tags.pool.empty?
              self.tags.pool.each do |tag|
                if tag.match(regex)
                  mar = filt.length.to_f / tag.length.to_f
                  self.adj_mar(mar)
                  tagmatch = true

                else
                  # puts "#{tag} doesn't match #{regex}"
                  self.adj_mar
                end
              end
            end

            good += 1 if tagmatch
          end

          ret = true if good >= goodlim
        end
      end

      return ret
    end



    # MAR: Match Accuracy Rating
    def mar
      ret = 0

      if self.mars.length > 0
        ttl = 0
        # puts "#{self.val.str}: #{self.mars.to_s}"
        self.mars.each { |x| ttl += x }
        ret = (ttl / self.mars.length)
      end

      return ret
    end



    def adj_mar( score = 0 )
      self.mars.push(score)
    end


  end
end
