#
# You're it.
#



module Star
  class Tags < Star::Line


    def initialize( tags = nil )
      @pool = [ ]

      if tags.is_a? String
        self.from_s(tags)
      elsif tags.is_a? Array
        self.sort!
      end
    end

    attr_accessor :pool



    def from_s( str = '' )
      self.pool = self.sort(str.split(Star::Utils.unit_sep))
    end


    def to_s
      self.sort!
      self.pool.join(Star::Utils.unit_sep)
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
