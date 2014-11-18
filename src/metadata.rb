module BM
  class Metadata < BM::Line


    def self._h( arr = [0, 0, 0] )
      {
        :time_created => arr[0],
        :time_touched => arr[1],
        :touch_count  => arr[2]
      }
    end


    def self.to_h( str = '' )
      return BM::Metadata._h(str.split(BM::Utils.unit_sep))
    end


  end
end
