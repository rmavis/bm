#
# Methods related to the store file.
#



module Star
  class Store


    def initialize( conf = nil )
      @conf, @futil = nil, nil
      @file_path, @file_name = '', ''

      if conf.is_a? Star::Config
        @conf = conf
        p = File.expand_path @conf.file_name
        @file_name = File.basename p
        @file_path = File.dirname p
        @futil = Star::Fileutils.new @conf.file_name
      end

      @bk_file, @has_file, @nil_file = nil, nil, nil

      self.fix_path_name
      self.check_file!
    end

    attr_reader :conf, :futil
    attr_accessor :file_path, :file_name, :bk_file, :has_file, :nil_file



    def file
      self.file_path + '/' + self.file_name
    end


    def fix_path_name
      p = self.file_path.strip
      p = p.chomp('/') if p.end_with?('/')
      return self.file_path
    end


    def make_file
      if self.futil.dir? or self.futil.make_dir!
        self.futil.make!
      end

      self.check_file!

      if self.has_file
        puts Star::Message.out(:init, self.file)
        ret = true
      else
        puts Star::Message.out(:filefail, self.file)
        ret = nil
      end

      return ret
    end


    def check_file!
      self.has_file = self.has_file?
      self.nil_file = self.file_empty?
    end

    def has_path?;  self.futil.dir? end
    def has_file?;  self.futil.exists? end
    def file_empty?; self.futil.empty? end



    def make_backup_file( ext = Star::Fileutils.backup_ext, cp_file = true )
      self.bk_file = self.file + ext
      IO.copy_stream(self.file, self.bk_file) if cp_file
      return self.bk_file
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
          puts Star::Message.out(:fileempty, self.file)
        else
          puts Star::Message.out(:fileexists, self.file)
        end

      else
        self.make_file
      end
    end



    def append?( line = nil )
      ret = nil

      self.make_file if !self.has_file?

      if self.has_file and line.is_a?(Star::Line)
        fh = File.open(self.file, 'a')
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
      if tags.empty?
        puts Star::Message.out(:tagsno)
      else
        tags.each { |tag,count| puts "#{tag} (#{count})" }
      end
    end


    def cull_tags
      ret = { }

      if self.has_file and !self.nil_file
        fh = File.open(self.file, 'r')

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
