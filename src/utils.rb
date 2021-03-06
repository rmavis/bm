module Star
  class Utils


    # The ASCII group separator character.
    def self.grp_sep
      ""
    end

    # The ASCII record separator character.
    def self.rec_sep
      ""
    end

    # The ASCII unit separator character.
    def self.unit_sep
      ""
    end



    # Characters that need to be escaped.
    def self.escapes
      ["`", '"']
    end



    def self.escape( str = '' )
      ret = str

      Star::Utils.escapes.each do |esc|
        ret = ret.gsub(esc){ "\\#{esc}" }
      end

      return ret
    end



    def self.clean( str = '' )
      ret = str

      Star::Utils.escapes.each do |esc|
        ret = ret.gsub("\\#{esc}"){ esc }
      end

      return ret
    end


  end
end
