#
# The little meta.
#



module Star
  class Metadata < Star::Line


    def initialize( mdata = nil )
      @time_created, @time_touched, @touch_count = 0, 0, 0

      mdata = mdata.split(Star::Utils.unit_sep) if mdata.is_a?(String)
      self.from_s if mdata.is_a?(Array)
    end

    attr_accessor :time_created, :time_touched, :touch_count



    def ini
      now = Time.now.to_i
      self.time_created = now
      self.time_touched = 0
      self.touch_count  = 0
    end



    def from_s( str = '' )
      arr = str.split Star::Utils.unit_sep

      if arr.is_a? Array
        if arr.length == 3
          self.time_created = arr[0].to_i
          self.time_touched = arr[1].to_i
          self.touch_count = arr[2].to_i

        else
          raise Exception.new("Invalid metadata array: #{arr.to_s}. Should have 3 elements.")
        end
      else
        raise Exception.new("Metadata string failed to split properly.")
      end
    end



    def to_s
      ret =
        "#{self.time_created}#{Star::Utils.unit_sep}" +
        "#{self.time_touched}#{Star::Utils.unit_sep}" +
        "#{self.touch_count}"
    end



    def touch
      self.time_touched = Time.now.to_i
      self.touch_count += 1
    end



    def to_a
      [ self.time_created. self.time_touched, self.touch_count ]
    end

  end
end
