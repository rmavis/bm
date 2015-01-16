#
# For the sake of arguments.
#


module Star
  class Args < Star::Hub


    # Pass this the arguments array (ARGV), a  and it will return a
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
      if (((!args.is_a? Array) or (args.is_a?(Array) and args.empty?)) and demo.nil?)
        ret[:act] = :commands

      else
        wantargs = true

        while args[0].is_a? String and args[0].match(/^-+[a-z]+/)
          x = args[0].downcase.strip

          if ((x == "-a") or (x == "--all"))
            wantargs = nil
          elsif ((x == "-c") or (x == "--commands") or
                 (x == "-f") or (x == "--flags"))
            ret[:act], wantargs = :commands, nil
          elsif ((x == "-d") or (x == "--delete"))
            ret[:act] = :delete
          elsif ((x == "-i") or (x == "--init"))
            ret[:act] = :init
          elsif ((x == "-l") or (x == "--loose"))
            ret[:filtmode] = :loose
          elsif ((x == "-m") or (x == "--demo"))
            ret[:act] = (demo) ? :demodup : :demo
          elsif ((x == "-n") or (x == "--new"))
            ret[:act] = :new
          elsif ((x == "-o") or (x == "--open"))
            ret[:act] = :open
          elsif ((x == "-p") or (x == "--copy"))
            ret[:act] = :copy
          elsif ((x == "-r") or (x == "--readme") or
                 (x == "-h") or (x == "--help"))
            ret[:act], wantargs = :help, nil
          elsif ((x == "-rx") or (x == "-xr") or
                 (x == "-hx") or (x == "-xh"))
            ret[:act], wantargs = :helpx, nil
          elsif ((x == "-s") or (x == "--strict"))
            ret[:filtmode] = :strict
          elsif ((x == "-t") or (x == "--tags"))
            ret[:act] = :tags
          elsif ((x == "-x") or (x == "--examples"))
            ret[:act] = :examples
          elsif (x.match(/^-+[a-z]+/))
            ret[:act] = :err
          end

          args.delete_at(0)
          break if ret[:act] == :demo
        end

        ret[:act] = :read if ret[:act].nil?
        ret[:args] = args if wantargs
      end

      return ret
    end



    # This only works with numbers.
    def self.parse_lines_prompt( str = '' )
      ret = nil

      if str.is_a? String
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
