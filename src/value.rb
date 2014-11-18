#
# Methods related to the value.
#



module BM
  class Value < BM::BM


    # Characters that need to be escaped.
    def self.escapes
      ["`", '"']
    end



    # This chops the value field from the given line and saves it.
    def chop_val!
      ret, str = nil, self.line

      if str.is_a? String
        ret = (str.include? BM.unit_sep) ? str.split(BM.unit_sep).last : str
        ret = ret.strip
      end

      self.val = ret
    end



    def copy_val
      chk = self.copy_val?
      if chk.nil?
        ret = BM::Message.out(:pipefail)
      else
        ret = BM::Message.out(:pipeok, self.clean(self.val))
      end
      return ret
    end


    def copy_val?(str = self.val)
      return nil if !str.is_a? String

      # Echo's -n flag doesn't work as expected here. It gets copied.
      #chk = system("echo -n \"#{str}\" | pbcopy")
      chk = system("printf \"#{str.gsub(/%/, '%%')}\" | pbcopy")
      ret = (chk) ? true : nil
      return ret
    end



    def open_val
      chk = self.open_val?
      if chk.nil?
        ret = BM::Message.out(:openfail)
      else
        ret = BM::Message.out(:openok, self.clean(self.val))
      end
      return ret
    end


    def open_val?(str = self.val)
      return nil if !str.is_a? String

      chk = system("open \"#{self.val}\"")
      ret = (chk) ? true : nil
      return ret
    end


  end
end
