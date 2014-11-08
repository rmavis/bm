#
# Methods related to the file.
#



module BM
  class Store


    def self.file_path
      File.expand_path(BM.file_name)
    end

    def self.has_file?
      if File.file?(BM.file_path) then true else nil end
    end


    def self.backup_ext
      ".bk"
    end

    def self.demo_ext
      ".demo"
    end

    def self.backup_file_name(ext = BM.backup_ext)
      BM.file_name + ext
    end

    def self.backup_file_path(ext = BM.backup_ext)
      File.expand_path(BM.backup_file_name(ext))
    end


    # The ASCII group separator character.
    def self.group_sep
      ""
    end

    # The ASCII record separator character.
    def self.line_sep
      ""
    end

    # The ASCII unit separator character.
    def self.tag_sep
      ""
    end


    # Characters that need to be escaped.
    def self.escapes
      ["`", '"']
    end




    def check_file!
      self.has_file, self.nil_file = self.has_file?, self.file_empty?
    end

    def has_file?
      if File.file?(self.file_path) then true else nil end
    end

    def file_empty?
      if File.zero?(self.file_path) then true else nil end
    end


    def make_file
      f = File.new(self.file_path, 'w+', 0600)
      self.check_file!  # Updates the @has_file and @nil_file bools.
      return self.has_file
    end

    def make_backup_file!
      self.bk_file = self.file_path + BM.backup_ext 
      IO.copy_stream(self.file_path, self.bk_file)
    end

    def delete_backup_file!
      File.delete(self.bk_file)
      self.bk_file = nil
    end


    # When the action is init, main calls this.
    def init_file
      if self.has_file
        if self.nil_file
          ret = self.out_msg(:fileempty)
        else
          ret = self.out_msg(:fileexists)
        end
      else
        if self.make_file
          ret = self.out_msg(:init)
        else
          ret = self.out_msg(:filefail)
        end
      end

      return ret
    end


  end
end
