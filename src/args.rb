#
# For the sake of arguments.
#



module BM
  class Args


    # Pass this the arguments array (argv) and it will return a
    # hash containing four keys:
    # - :act, indicating the action for the main routine to take
    # - :args, which are the arguments for the specified action
    # - :filtmode, which, if not specified on the command line,
    #    will be the class default
    # - :pipeto, which acts akin to :filtmode
    def parse_args(args = [ ], demo = nil)
      ret = {
        :act => nil, :args => [ ],
        :pipeto => BM.default_pipe_to,
        :filtmode => BM.default_filter_mode
      }

      # If there are no args, assume help is needed.
      if ((!args.is_a? Array) or ((args.is_a? Array) and (args.empty?)))
        ret[:act] = (demo.nil?) ? :commands : :read

      else
        wantargs = true

        while args[0].is_a? String and args[0].match(/^-+[a-z]+/)
          x = args[0].downcase.strip

          if ((x == "-a") or (x == "--all"))
            ret[:act], wantargs = :read, nil
          elsif ((x == "-c") or (x == "--commands"))
            ret[:act], wantargs = :commands, nil
          elsif ((x == "-d") or (x == "--delete"))
            ret[:act] = :delete
          elsif ((x == "-i") or (x == "--init"))
            ret[:act] = :init
          elsif ((x == "-l") or (x == "--loose"))
            ret[:filtmode] = :loose
          elsif ((x == "-m") or (x == "--demo"))
            ret[:act] = :demo
          elsif ((x == "-n") or (x == "--new"))
            ret[:act] = :new
          elsif ((x == "-o") or (x == "--open"))
            ret[:pipeto] = :open
          elsif ((x == "-p") or (x == "--copy"))
            ret[:pipeto] = :copy
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

        # No meta-demos allowed.
        ret[:act] = :demodup if (demo) and (ret[:act] == :demo)
      end

      return ret
    end



    def args_to_filts(args = self.args)
      # They are escaped because they are stored escaped.
      args.collect! { |f| self.escape(f).downcase }
      return args.uniq
    end


  end
end
