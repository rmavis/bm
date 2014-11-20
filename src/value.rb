#
# Methods related to the value.
#



module Bm
  class Value < Bm::Line


    # Characters that need to be escaped.
    def self.escapes
      ["`", '"']
    end



    def initialize( str = nil )
      @str = (str.is_a? String) ? str : nil
    end

    attr_accessor :str



    def downcase
      if (self.str.is_a? String) then self.str.downcase else '' end
    end



    # This chops the value field from the given line and saves it.
    def chop_val!
      ret, str = nil, self.line

      if str.is_a? String
        ret = (str.include? Bm.unit_sep) ? str.split(Bm.unit_sep).last : str
        ret = ret.strip
      end

      self.str = ret
    end



    def copy
      if self.sys_copy
        puts Bm::Message.out(:pipeok, Bm::Utils.clean(self.str))
      else
        puts Bm::Message.out(:pipefail)
      end
    end


    def sys_copy
      ret = nil

      if self.str.is_a? String
        # Echo's -n flag doesn't work as expected here. It gets copied.
        #chk = system("echo -n \"#{str}\" | pbcopy")
        chk = system("printf \"#{self.str.gsub(/%/, '%%')}\" | pbcopy")
        ret = (chk) ? true : nil
      end

      return ret
    end



    def open
      if self.sys_open
        puts Bm::Message.out(:openok, Bm::Utils.clean(self.str))
      else
        puts Bm::Message.out(:openfail)
      end
    end


    def sys_open
      ret = nil

      if self.str.is_a? String
        chk = system("open \"#{self.str}\"")
        ret = (chk) ? true : nil
      end

      return ret
    end


  end
end
