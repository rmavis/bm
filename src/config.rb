#
# For configuration.
#



require 'yaml'

module Star
  class Config


    def self.config_dir
      "~/.config/star"
    end

    def self.config_file_name
      "config.yaml"
    end

    def self.store_file_name
      "store"
    end

    def self.config_file
      "#{Star::Config.config_dir}/#{Star::Config.config_file_name}"
    end

    def self.store_file
      "#{Star::Config.config_dir}/#{Star::Config.store_file_name}"
    end


    def self.filter_modes
      [:strict, :loose]
    end

    def self.pipe_tos
      [:copy, :open]
    end


    def self.default_filter_mode
      Star::Config.filter_modes.first
    end

    def self.default_pipe_to
      Star::Config.pipe_tos.first
    end

    def self.default_edit_head
      true
    end

    def self.default_edit_space
      true
    end


    def self.default_config_file
      defs, ret = Star::Config.defaults, ''
      defs.each { |sym,h| ret << "#{h[:key]}: #{h[:val].to_s}\n" }
      return ret
    end


    def self.valid_filter_mode?( chk )
      if self.filter_modes.include?(chk) then true else nil end
    end

    def self.valid_pipe_to?( chk )
      if self.pipe_tos.include?(chk) then true else nil end
    end


    def self.filter_mode_sym( chk )
      chk = chk.to_sym if chk.is_a? String
      ret = Star::Config.default_filter_mode
      ret = chk if Star::Config.valid_filter_mode?(chk)
      return ret
    end

    def self.pipe_to_sym( chk )
      chk = chk.to_sym if chk.is_a? String
      ret = Star::Config.default_pipe_to
      ret = chk if Star::Config.valid_pipe_to?(chk)
      return ret
    end



    def self.defaults
      {
       :edit_head => {
          :key => 'edit_header_message',
          :val => Star::Config.default_edit_head
        },
       :edit_space => {
          :key => 'edit_extra_space',
          :val => Star::Config.default_edit_space
        },
        :file_name => {
          :key => 'file_name',
          :val => Star::Config.store_file
        },
        :filter_mode => {
          :key => 'filter_mode',
          :val => Star::Config.default_filter_mode
        },
        :pipe_to => {
          :key => 'pipe_to',
          :val => Star::Config.default_pipe_to
        }
      }
    end


    def self.settings
      defs = Star::Config.defaults

      conf_f = File.expand_path(Star::Config.config_file)
      if File.file?(conf_f)
        vars = YAML.load_file(conf_f)

        defs.each do |sym,h|
          # puts h.to_s
          if vars.has_key?(h[:key])
            chk = vars[h[:key]]
            # puts "Checking #{chk}"

            #
            # IMPORTANT
            # Need to ensure that the values below are valid.
            #

            if sym == :edit_head
              defs[sym] = (chk == true) ? true : nil
            elsif sym == :edit_space
              defs[sym] = (chk == true) ? true : nil
            elsif sym == :file_name
              defs[sym] = (chk.nil?) ? Star::Config.store_file : chk
            elsif sym == :filter_mode
              defs[sym] = Star::Config.filter_mode_sym(chk)
            elsif sym == :pipe_to
              defs[sym] = Star::Config.pipe_to_sym(chk)
            else
              # puts "argh: #{h[:key]}"
            end

          else
            # puts "key not in config file: #{h[:key]}"
          end

        end

      else
        defs.each { |sym,h| defs[sym] = h[:val] }          
      end

      # puts "SETTINGS: #{defs}"
      return defs
    end




    def initialize( settings = nil )
      @h = (settings.is_a?(Hash)) ? settings : Star::Config.settings
    end

    attr_reader :h



    def edit_head?
      if self.h[:edit_head] then true else nil end
    end

    def edit_space?
      if self.h[:edit_space] then true else nil end
    end

    def file_name
      self.h[:file_name]
    end

    def filter_mode
      self.h[:filter_mode]
    end

    def pipe_to
      self.h[:pipe_to]
    end


    def path
      File.expand_path(Star::Config.config_dir)
    end

    def full_file_name
      File.expand_path(self.file_name)
    end



    def save_settings
      fu = Star::Fileutils.new(Star::Config.config_file)

      if !fu.dir? || !fu.make_dir!
        puts Star::Message.out(:conffail, fu.dir)

      else
        if fu.exists?
          fh = File.open(fu.full, 'w+')
        else
          fh = File.new(fu.full, 'w+', 0600)
        end

        if fh
          Star::Config.defaults.each do |sym,h|
            fh.puts "#{h[:key]}: #{self.h[sym]}"
          end
          fh.close

          if fu.exists?
            puts Star::Message.out(:confok, fu.full)
          else
            puts Star::Message.out(:confnok)
          end

        else
          puts Star::Message.out(:conffail)
        end        
      end
    end

  end
end
