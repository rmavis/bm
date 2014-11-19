#
# Methods related to the file.
#



module Bm
  class Store < Bm::Hub


    def self.file_name
      Bm::Config.file_name
    end

    def self.file_path
      File.expand_path(Bm::Config.file_name)
    end


    def self.backup_ext
      ".bk"
    end

    def self.temp_ext
      ".tmp"
    end


    def self.backup_file_name( ext = Bm::Store.backup_ext )
      Bm::Store.file_name + ext
    end

    def self.backup_file_path( ext = Bm::Store.backup_ext )
      File.expand_path(Bm::Store.backup_file_name(ext))
    end


    def self.has_file?
      if File.file?(Bm::Store.file_path) then true else nil end
    end



    def initialize( file = Bm::Config.file_name )
      @path, @name = '', ''

      if file.is_a? String
        p = File.expand_path(file)
        @name = File.basename(p)
        @path = File.dirname(p)
      end

      @has_file, @nil_file = nil, nil

      self.fix_path_name
      self.check_file!
    end

    attr_accessor :path, :name, :has_file, :nil_file



    def file_path
      self.path + self.name
    end


    def fix_path_name
      p = self.path.strip
      self.path << '/' if !p.end_with?('/')
      return self.path
    end


    def check_file!
      if self.has_file?
        self.has_file = true
      elsif self.has_path?
        self.has_file = self.make_file
      else
        self.has_file = self.make_path and self.make_file
      end

      self.nil_file = self.file_empty?
    end


    def has_file?
      if File.file?(self.file_path) then true else nil end
    end

    def has_path?
      if Dir.exists?(self.path) then true else nil end
    end


    def file_empty?
      if File.zero?(self.file_path) then true else nil end
    end


    def make_file
      f = File.new(self.file_path, 'w+', 0600)
      return self.has_file?
    end

    def make_path
      d = Dir.mkdir(self.path)
      return self.has_path?
    end


    def make_backup_file!
      self.bk_file = self.file_path + Bm::Store.backup_ext 
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
          ret = Bm::Message.out(:fileempty)
        else
          ret = Bm::Message.out(:fileexists)
        end
      else
        if self.make_file
          ret = Bm::Message.out(:init)
        else
          ret = Bm::Message.out(:filefail)
        end
      end

      return ret
    end


  end
end
