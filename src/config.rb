#
# Configuration variables.
#
# If you want to change the default file, filter mode, or system call,
# then change the value of one of these methods.
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

            if sym == :file_name
              defs[sym] = chk
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
      end

      # puts defs
      return defs
    end




    def initialize
      @h = Star::Config.settings
    end

    attr_reader :h


    def file_name
      self.h[:file_name]
    end

    def filter_mode
      self.h[:filter_mode]
    end

    def pipe_to
      self.h[:pipe_to]
    end

  end
end
