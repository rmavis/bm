#
# You're it.
#



module Star
  class Tags < Star::Line


    def initialize( tags = nil )
      @pool = [ ]
      @swap = nil

      if tags.is_a?(String)
        self.from_s(tags)
      elsif tags.is_a?(Array)
        self.sort!
      end
    end

    attr_accessor :pool, :swap



    def from_s( str = '' )
      self.pool = self.sort(str.split(Star::Utils.unit_sep))
    end



    def to_s( use_swap = nil )
      if use_swap
        swaps = self.sort(self.swap)
        self.swap.join(Star::Utils.unit_sep)
      else
        self.sort!
        self.pool.join(Star::Utils.unit_sep)
      end
    end



    def sort( arr = self.pool )
      ret = (arr.empty?) ? [ ] : arr.sort.collect { |t| t.strip }
      return ret
    end



    def sort!
      self.pool = self.sort
    end


  end
end
