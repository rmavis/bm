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


    def fill_from_args( args = self.hub.args || [ ] )
      if self.hub.is_a?(Star::Hub) and self.hub.args.is_a?(Array)
        self.fill_from_array self.hub.args

      else
        # Should an error go #HERE?
      end
    end



    def fill_from_array( arr = [ ] )
      if arr.is_a?(Array) and !arr.empty?
        self.val.str = arr.pop.strip
        self.tags.pool = arr
        self.meta.ini

      else
        # Should an error go #HERE?
      end
    end




    # This method performs two functions.
    # For each line, it checks if the value and tags contain the filters.
    # If so, then it adds the match's MAR to the mars array.
    # It also checks that the line matches the required number of matches.
    # If the match mode is loose, then one match will suffice.
    # Else, the line must match each tag.

    def matches?( filts = [ ], incluv = nil )
      ret = nil

      if !self.val.str.empty?
        if filts.empty?
          ret = true

        else
          goodlim = (incluv) ? 1 : filts.length

          filts.each do |filt|
            regex = '.*' + filt.downcase + '.*'

            if self.val.str.downcase.match(regex)
              mar = filt.length.to_f / self.val.str.length.to_f
              self.add_mar(mar)
            end

            if !self.tags.pool.empty?
              self.tags.pool.each do |tag|
                # puts "#{tag.downcase} & #{self.val.str.downcase} vs #{regex}"

                if tag.downcase.match(regex)
                  mar = filt.length.to_f / tag.length.to_f
                  self.add_mar(mar)

                else
                  # puts "#{tag} doesn't match #{regex}"
                  self.add_mar
                end
              end
            end

          end

          ret = true if self.matches >= goodlim
        end
      end

      return ret
    end



    def matches
      ret = 0
      self.mars.each { |x| ret += 1 if x > 0 }
      return ret
    end



    def add_mar( score = 0 )
      self.mars.push(score)
    end



    # Average Match Accuracy Rating.
    def avg_mar( adj = nil )
      ret = 0

      if self.mars.length > 0
        ttl = 0
        # puts "#{self.val.str}: #{self.mars.to_s}"

        if adj
          self.mars.each do |mar|
            ret = 1 if mar == 1
            ttl += mar
          end

          ret = (ttl / self.mars.length) if ret == 0

        else
          self.mars.each { |x| ttl += x }
          ret = (ttl / self.mars.length)
        end
      end

      return ret
    end


    def adj_mar
      return self.avg_mar(true)
    end


  end
end
