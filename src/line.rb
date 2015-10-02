#
# Methods related to the line.
#


module Star
  class Line


    def self.new_from_args( hub )
      if hub.is_a?(Star::Hub)

        line = Star::Line.new(hub)
        line.fill_from_args

        if hub.store.append?(line)
          puts Star::Message.out(:saveok)
        else
          puts Star::Message.out(:savefail)
        end

      else
        raise Exception.new("Can't create new STAR Line: need a Hub.")
      end
    end



    def self.edit_line_parts
      return {
        :index => nil,
        :value => nil,
        :tags => nil
      }
    end




    def initialize( ini = nil )
      @val, @tags, @meta = Star::Value.new, Star::Tags.new, Star::Metadata.new
      @str, @hub, @mars, @mar, @mlim = nil, nil, [ ], 0, 0
      @del = nil

      if ini.is_a?(String)
        @str = ini
        self.from_s
      elsif ini.is_a?(Star::Hub)
        @hub = ini
      end
    end

    attr_reader :hub
    attr_accessor :str, :val, :tags, :meta, :mars, :mar, :mlim, :del



    def blank?
      if (self.str.is_a? String) then nil else true end
    end



    def to_s( add_sep = nil, use_swaps = nil )
      if use_swaps
        str =
          self.val.to_s(use_swaps) + Star::Utils.rec_sep +
          self.tags.to_s(use_swaps) + Star::Utils.rec_sep +
          self.meta.to_s

      else
        str =
          self.val.to_s + Star::Utils.rec_sep +
          self.tags.to_s + Star::Utils.rec_sep +
          self.meta.to_s
      end

      str << Star::Utils.grp_sep if add_sep

      return str
    end



    def from_s
      arr = self.str.split(Star::Utils.rec_sep)

      if arr.is_a?(Array)
        if arr.length == 3
          self.val.from_s(arr[0])
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
      if self.hub.is_a?(Star::Hub) && self.hub.args.is_a?(Array)
        self.fill_from_array(self.hub.args)

      else
        # Should an error go #HERE?
      end
    end



    def fill_from_array( arr = [ ] )
      if arr.is_a?(Array) && !arr.empty?
        tags = self.val.from_arr!(arr)
        self.tags.pool = tags
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

      self.mlim = (incluv.nil?) ? filts.length : 1
      self.add_mar

      if !self.val.str.empty?
        if filts.empty?
          ret = true

        else
          pos = 0

          if incluv.nil?  # Strict.
            pattern_brackets = '\W'
            match_mode = :strict
          else  # Loose.
            pattern_brackets = '.*'
            match_mode = :loose
          end

          str_dc = (self.val.str.is_a?(String)) ? self.val.str.downcase : nil
          ttl_dc = (self.val.title.is_a?(String)) ? self.val.title.downcase : nil

          filts.each do |filt|
            filt_dc = filt.downcase
            regex = pattern_brackets + filt_dc + pattern_brackets

            if str_dc.is_a?(String) && ((str_dc == filt_dc) || (str_dc.match(regex)))
              mar = filt.length.to_f / self.val.str.length.to_f
              self.add_mar(pos, mar)
            else
              self.add_mar(pos)
            end

            if ttl_dc.is_a?(String) && ((ttl_dc == filt_dc) || (ttl_dc.match(regex)))
              mar = filt.length.to_f / self.val.title.length.to_f
              self.add_mar(pos, mar)
            end

            if !self.tags.pool.empty?
              self.tags.pool.each do |tag|
                test = (match_mode == :strict) ? filt : regex

                if tag.downcase.mode_match(match_mode, test)
                  mar = filt.length.to_f / tag.length.to_f
                  self.add_mar(pos, mar)
                else
                  self.add_mar(pos)
                end
              end
            end

            pos += 1
          end

          if self.match_lim?(incluv)
            self.avg_mars!
            ret = true
            # puts "mars: #{self.mars} // avgmar: #{self.mar} // val: (#{self.val.str})"
          end
        end
      end

      return ret
    end



    def match_lim?( incluv = nil )
      chk = 0.0

      if incluv
        self.mars.each { |x| chk += 1 if x > 0 }
      else
        self.mars.each { |x| chk += x }
      end

      if (chk >= self.mlim) then true else nil end
    end



    def add_mar( pos = 0, score = 0 )
      score = 0 if !score.is_a?(Numeric)
      self.mars[pos] = 0 if self.mars[pos].nil?
      self.mars[pos] = score if score > self.mars[pos]
    end



    # Average Match Accuracy Rating.
    def avg_mars!
      ret, ttl = 0.0, 0.0

      if self.mars.length > 0
        self.mars.each { |x| ttl += x }
        ret = (ttl / self.mars.length)
      end

      self.mar = ret
      return self.mar
    end

  end
end
