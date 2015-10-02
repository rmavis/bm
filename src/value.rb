#
# Methods related to the value.
#



module Star
  class Value < Star::Line


    # Characters that need to be escaped.
    def self.escapes
      ["`", '"']
    end



    def initialize( str = nil, title = nil )
      @str = (str.is_a?(String)) ? str : nil
      @title = (title.is_a?(String)) ? title : nil

      @swap_str = nil
      @swap_title = nil
    end

    attr_accessor :str, :title, :swap_str, :swap_title



    def to_s( swaps = nil )
      if swaps.nil?
        if self.str.is_a?(String) && self.title.is_a?(String)
          return "#{self.str}#{Star::Utils.unit_sep}#{self.title}"
        else
          return self.str
        end

      else
        if self.swap_str.is_a?(String) && self.swap_title.is_a?(String)
          return "#{self.swap_str}#{Star::Utils.unit_sep}#{self.swap_title}"
        else
          return self.swap_str
        end
      end
    end



    def from_s( str = '' )
      arr = str.split(Star::Utils.unit_sep)

      if arr.is_a?(Array)
        if arr.length == 1
          self.str = arr[0].strip

        elsif arr.length == 2
          self.str = arr[0].strip
          self.title = arr[1].strip

        else
          raise Exception.new("Invalid value array: #{arr.to_s}. Should have at most 2 elements.")
        end

      else
        raise Exception.new("Value string failed to split properly.")
      end
    end



    # This will remove the value and title (if it exists) elements
    # from the given array and set those to the matching attributes
    # of self. The array it returns will contain the line's tags.
    def from_arr!( arr = [ ] )
      ret = [ ]

      arr.each do |elem|
        if elem.is_a?(Hash)
          self.title = elem[:title].strip if elem.has_key?(:title)
        else
          ret.push(elem.strip)
        end
      end

      self.str = ret.pop.strip

      return ret
    end



    def downcase
      if self.str.is_a?(String)
        return self.str.downcase
      else
        return ''
      end
    end



    # This chops the value field from the given line and saves it.
    def chop_val!
      ret, str = nil, self.line

      if str.is_a?(String)
        ret = (str.include?(Star.unit_sep)) ? str.split(Star.unit_sep).last : str
        ret = ret.strip
      end

      self.str = ret
    end



    def copy
      if self.sys_copy
        puts Star::Message.out(:pipeok, Star::Utils.clean(self.str))
      else
        puts Star::Message.out(:pipefail)
      end
    end


    def sys_copy
      ret = nil

      if self.str.is_a?(String)
        # Echo's -n flag doesn't work as expected here. It gets copied.
        #chk = system("echo -n \"#{str}\" | pbcopy")
        chk = system("printf \"#{self.str.gsub(/%/, '%%')}\" | pbcopy")
        ret = (chk) ? true : nil
      end

      return ret
    end



    def open
      if self.sys_open
        puts Star::Message.out(:openok, Star::Utils.clean(self.str))
      else
        puts Star::Message.out(:openfail)
      end
    end


    def sys_open
      ret = nil

      if self.str.is_a?(String)
        chk = system("open \"#{self.str}\"")
        ret = (chk) ? true : nil
      end

      return ret
    end


  end
end
