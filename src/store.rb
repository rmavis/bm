#
# Methods related to the file.
#



module Star
  class Store < Star::Hub


    def self.file_name
      Star::Config.file_name
    end

    def self.file_path
      File.expand_path(Star::Config.file_name)
    end


    def self.backup_ext
      ".bk"
    end

    def self.temp_ext
      ".tmp"
    end


    def self.backup_file_name( ext = Star::Store.backup_ext )
      Star::Store.file_name + ext
    end

    def self.backup_file_path( ext = Star::Store.backup_ext )
      File.expand_path(Star::Store.backup_file_name(ext))
    end


    def self.has_file?
      if File.file?(Star::Store.file_path) then true else nil end
    end




    def initialize( file = Star::Config.file_name )
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


    def has_file?
      if File.file?(self.file_path) then true else nil end
    end

    def has_path?
      if Dir.exists?(self.path) then true else nil end
    end

    def file_empty?
      if File.zero?(self.file_path) then true else nil end
    end

    def check_file!
      self.has_file = self.has_file?
      self.nil_file = self.file_empty?
    end



    def make_file
      if self.has_path? or self.make_path
        File.new(self.file_path, 'w+', 0600)
      end

      self.check_file!

      if self.has_file
        puts Star::Message.out :init
        ret = true
      else
        puts Star::Message.out :filefail
        ret = nil
      end

      return ret
    end


    def make_path
      Dir.mkdir(self.path) if !self.has_path?
      return self.has_path?
    end


    def make_backup_file!
      self.bk_file = self.file_path + Star::Store.backup_ext 
      IO.copy_stream(self.file_path, self.bk_file)
    end

    def delete_backup_file!
      File.delete(self.bk_file)
      self.bk_file = nil
    end




    # When the action is init, main calls this.
    # @has_file and @nil_file are set during initialization.

    def init_file
      if self.has_file
        if self.nil_file
          puts Star::Message.out :fileempty
        else
          puts Star::Message.out :fileexists
        end

      else
        self.make_file
      end
    end



    def append?( line = nil )
      ret = nil

      self.make_file if !self.has_file?

      if self.has_file and line.is_a?(Star::Line)
        fh = File.open(self.file_path, 'a')
        fh.puts line.to_s(true)
        fh.close
        ret = true
      end

      return ret
    end




    #
    # These two methods comprise the tags report.
    #

    def print_tags_report
      tags = self.cull_tags
      tags.each { |tag,count| puts "#{tag} (#{count})" }
    end


    def cull_tags
      ret = { }

      if self.has_file and !self.nil_file
        fh = File.open(self.file_path, 'r')

        while l_str = fh.gets(Star::Utils.grp_sep)
          l_obj = Star::Line.new(l_str)

          if !l_obj.tags.pool.empty?
            l_obj.tags.pool.each do |tag|
              ret[tag] = 0 if !ret.has_key?(tag)
              ret[tag] += 1
            end
          end
        end

        keys, tmp = ret.keys.sort, { }
        keys.each { |k| tmp[k] = ret[k] }
        ret, tmp = tmp, nil
      end

      return ret
    end


  end
end
