#
# Methods related to the value.
#



module BM
  class Value


    # This chops the value field from the given line and saves it.
    def chop_val!
      ret, str = nil, self.line

      if str.is_a? String
        ret = (str.include? BM.tag_sep) ? str.split(BM.tag_sep).last : str
        ret = ret.strip
      end

      self.val = ret
    end



    def copy_val
      chk = self.copy_val?
      if chk.nil?
        ret = self.out_msg(:pipefail)
      else
        ret = self.out_msg(:pipeok, self.clean(self.val))
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
        ret = self.out_msg(:openfail)
      else
        ret = self.out_msg(:openok, self.clean(self.val))
      end
      return ret
    end


    def open_val?(str = self.val)
      return nil if !str.is_a? String

      chk = system("open \"#{self.val}\"")
      ret = (chk) ? true : nil
      return ret
    end



    def get_system_action
      if self.pipe_to == :open
        ret = Proc.new { self.open_val }
      else
        ret = Proc.new { self.copy_val }
      end

      return ret
    end


  end
end
