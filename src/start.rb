#
# It's all happening.
#



module BM
  class Start


    def self.with( args = [ ] )
      Start.require_files
      bm = Start.new args
      bm.main
    end



    def self.required_files
      %w{ args.rb demo.rb etc.rb line.rb lines.rb message.rb store.rb tags.rb value.rb }
    end


    def self.require_files
      Start.required_files.each do |req|
        if File.exists? req
          require req
        else
          raise Exception.new("Can't run BM: missing required file '#{req}'.")
        end
      end
    end




    def initialize( args = [ ], demo = nil )
      argh = self.parse_args(args, demo)
      @act, @args, @filter_mode, @pipe_to = argh[:act], argh[:args], argh[:filtmode], argh[:pipeto]
      argh = nil

      if demo.nil?
        @file_name, @file_path = BM.file_name, BM.file_path
      else
        @file_name, @file_path = BM.backup_file_name(BM.demo_ext), BM.backup_file_path(BM.demo_ext)
      end

      @has_file, @nil_file, @bk_file = nil, nil, nil
      self.check_file!

      @lines, @tags, @line, @val = [ ], [ ], nil, nil
      @sysact = self.get_system_action
    end

    attr_reader :act, :args, :file_name, :file_path, :filter_mode, :pipe_to, :sysact
    attr_accessor :lines, :tags, :line, :val, :has_file, :nil_file, :bk_file



    def main
      ret = nil

      if (self.act == :read)
        ret = self.cull_lines

      elsif (self.act == :commands)
        puts BM.show_commands

      elsif (self.act == :delete)
        ret = self.delete_line

      elsif (self.act == :demo)
        ret = self.run_demo

      elsif (self.act == :demodup)
        ret = self.out_msg(:demodup)

      elsif (self.act == :err)
        ret = self.out_msg(:argsbad, true)

      elsif (self.act == :examples)
        puts BM.show_examples

      elsif (self.act == :help)
        puts BM.help_msg

      elsif (self.act == :helpx)
        puts BM.help_msg + "\n" + BM.extra_notes

      elsif (self.act == :init)
        ret = self.init_file

      elsif (self.act == :new)
        ret = self.new_line

      elsif (self.act == :tags)
        self.print_tags

      else   # Strange fire.
        ret = self.out_msg(:actbad, self.act)
      end

      puts ret if ret.is_a? String
    end


  end
end
