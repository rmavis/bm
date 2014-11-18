#
# The main meta?
# It's not even declassified yet.
#


module BM
  class BM


    def initialize( args = [ ], demo = nil )
      argh = BM::Args.parse(args, demo)
      @act, @args, @filter_mode, @pipe_to = argh[:act], argh[:args], argh[:filtmode], argh[:pipeto]

      @lines, @tags = BM::Lines.new, @tags = BM::Tags.new
      @line, @val = nil, nil

      if demo.nil?
        f_name, f_path = BM::Config.file_name, BM::Store.file_path
      else
        f_name, f_path = BM::Demo.file_name, BM::Demo.file_path
      end

      @sysact = self.get_system_action

      @store = BM::Store.new(f_path, f_name)
      @store.check_file!
    end

    attr_reader :act, :args, :filter_mode, :pipe_to, :sysact
    attr_accessor :store, :lines, :tags, :line, :val



    def main
      ret = nil

      if self.act == :read  #HERE
        ret = self.lines.cull

      elsif (self.act == :commands)
        puts BM::Message.show_commands

      elsif (self.act == :delete)
        ret = self.delete_line

      elsif (self.act == :demo)
        ret = BM::Demo.run(self.args)

      elsif (self.act == :demodup)
        ret = BM::Message.out(:demodup)

      elsif (self.act == :err)
        ret = BM::Message.out(:argsbad, true)

      elsif (self.act == :examples)
        puts BM::Message.show_examples

      elsif (self.act == :help)
        puts BM::Message.help_msg

      elsif (self.act == :helpx)
        puts BM::Message.help_msg + "\n" + BM::Message.extra_notes

      elsif (self.act == :init)
        ret = self.init_file

      elsif (self.act == :new)
        ret = self.new_line

      elsif (self.act == :tags)
        self.print_tags

      else   # Strange fire.
        ret = BM::Message.out(:actbad, self.act)
      end

      puts ret if ret.is_a? String
    end



    def get_system_action
      if self.pipe_to == :open
        ret = Proc.new { self.open_val }
      else
        ret = Proc.new { self.copy_val }
      end

      return ret
    end


  end
end
