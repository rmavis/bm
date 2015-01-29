#
# Basic file utilities.
#



module Star
  class Fileutils


    def self.backup_ext
      ".bk"
    end

    def self.temp_ext
      ".tmp"
    end




    def initialize( f_name = nil )
      if f_name.is_a? String
        @full = File.expand_path f_name
        @name = File.basename @full
        @dir = File.dirname @full
      else
        raise Exception.new("Can't create new Star::File: no name given.")
      end
    end

    attr_reader :full, :name, :dir



    def dir?
      if Dir.exists?(self.dir) then true else nil end
    end

    def exists?
      if File.exists?(self.full) then true else nil end
    end

    def empty?
      if File.zero?(self.full) then true else nil end
    end


    def make!
      self.make_dir!
      File.new(self.full, 'w+', 0600)
      return self.exists?
    end

    def make_dir!
      Dir.mkdir(self.dir) if !self.dir?
      return self.dir?
    end


  end
end
