#
# For the sake of arguments.
#


module Star
  class Args < Star::Hub


    # Pass this the arguments array (ARGV), and it will return a
    # hash containing three keys:
    # - :act, indicating the action for the main routine to take
    #   This will be :open, :copy, :delete, :demo, etc.
    # - :args, which are the arguments for the specified action
    #   These are cut from the command line
    # - :filtmode, which, if not specified on the command line,
    #    will be the class default

    def self.parse( args = [ ], demo = nil, config = nil )
      ret = {
        :act => nil, 
        :args => [ ],
        :filtmode => nil
      }

      if config.is_a?(Star::Config)
        ret[:act] = config.pipe_to
        ret[:filtmode] = config.filter_mode
      end

      # If there are no args, assume help is needed.
      if ((!args.is_a?(Array) || (args.is_a?(Array) && args.empty?)) && demo.nil?)
        ret[:act] = :commands

      else
        wantargs = true

        args.each do |arg|
          # while args[0].is_a?(String) && args[0].match(/^-+[a-z]+/)
          x = arg.downcase.strip

          if ((x == "-a") || (x == "--all"))
            wantargs = nil

          elsif ((x == "-c") || (x == "--commands") ||
                 (x == "-f") || (x == "--flags"))
            ret[:act], wantargs = :commands, nil

          elsif ((x == "-e") || (x == "--edit"))
            ret[:act] = :edit

          elsif ((x == "-d") || (x == "--delete"))
            ret[:act] = :delete

          elsif ((x == "-i") || (x == "--init"))
            ret[:act] = :init

          elsif ((x == "-l") || (x == "--loose"))
            ret[:filtmode] = :loose

          elsif ((x == "-m") || (x == "--demo"))
            ret[:act] = (demo.nil?) ? :demo : :demodup

          elsif ((x == "-n") || (x == "--new"))
            ret[:act] = :new

          elsif ((x == "-o") || (x == "--open"))
            ret[:act] = :open

          elsif ((x == "-p") || (x == "--copy"))
            ret[:act] = :copy

          elsif ((x == "-r") || (x == "--readme"))
            ret[:act], wantargs = :readme, nil

          elsif ((x == "-rx") || (x == "-xr"))
            ret[:act], wantargs = :readx, nil

          elsif ((x == "-h") || (x == "--help"))
            ret[:act], wantargs = :help, nil

          elsif ((x == "-hx") || (x == "-xh"))
            ret[:act], wantargs = :helpx, nil

          elsif ((x == "-s") || (x == "--strict"))
            ret[:filtmode] = :strict

          elsif ((x == "-t") || (x == "--tags"))
            ret[:act] = :tags

          elsif ((x == "-x") || (x == "--examples"))
            ret[:act], wantargs = :examples, nil

          elsif (title = arg.match(/^-+title:(.+)$/))
            ret[:args].push({ :title => title[1] }) if wantargs

          elsif (x.match(/^-+[a-z]+/))
            ret[:act] = :err

          else
            ret[:args].push(arg) if wantargs
          end

          break if ret[:act] == :demo
        end

        ret[:act] = :read if ret[:act].nil?
        # ret[:args] = args if wantargs
      end

      return ret
    end



    # This only works with numbers.
    def self.parse_lines_prompt( str = '' )
      ret = nil

      if str.is_a?(String)
        str = str.gsub(/[^0-9]+/, ' ').squeeze(' ').strip

        if str.empty?
          ret = [0]

        elsif str.include?(' ')
          ret = str.split(' ').uniq.collect { |n| n.to_i }

        else
          ret = [str.to_i]
        end
      end

      return ret
    end


  end
end
