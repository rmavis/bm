#!/usr/bin/ruby

#
# For a quick intro, type "bm -h".
#

module Bm
  class Hub


    # If it weren't for this one, all would be nothing.
    def self.with( args = [ ] )
      Bm::Hub.require_files
      bm = Bm::Hub.new args
      bm.main
    end



    def self.required_files
      %w{ args.rb config.rb demo.rb etc.rb line.rb lines.rb metadata.rb message.rb store.rb tags.rb utils.rb value.rb }
    end


    def self.require_files
      Bm::Hub.required_files.each do |req|
        req = File.expand_path("src/#{req}")
        if File.exists? req
          require_relative req
        else
          raise Exception.new("Can't run bm: missing required file '#{req}'.")
        end
      end
    end




    def initialize( args = [ ], demo = nil )
      argh = Bm::Args.parse(args, demo)
      @act, @args, @filter_mode, @pipe_to = argh[:act], argh[:args], argh[:filtmode], argh[:pipeto]

      f_name = (demo.nil?) ? Bm::Config.file_name : Bm::Demo.file_name
      @store = Bm::Store.new(f_name)
      @store.check_file!

      @sysact = self.get_system_action

      @lines = Bm::Lines.new self
    end

    attr_reader :act, :args, :filter_mode, :pipe_to, :sysact
    attr_accessor :store, :lines



    def main
      ret = nil

      if self.act == :read  #HERE
        self.lines.cull

      elsif (self.act == :commands)
        puts Bm::Message.show_commands

      elsif (self.act == :delete)
        ret = self.delete_line

      elsif (self.act == :demo)
        ret = Bm::Demo.run(self.args)

      elsif (self.act == :demodup)
        ret = Bm::Message.out(:demodup)

      elsif (self.act == :err)
        ret = Bm::Message.out(:argsbad, true)

      elsif (self.act == :examples)
        puts Bm::Message.show_examples

      elsif (self.act == :help)
        puts Bm::Message.help_msg

      elsif (self.act == :helpx)
        puts Bm::Message.help_msg + "\n" + Bm::Message.extra_notes

      elsif (self.act == :init)
        ret = self.init_file

      elsif (self.act == :new)
        ret = self.new_line

      elsif (self.act == :tags)
        self.print_tags

      else   # Strange fire.
        ret = Bm::Message.out(:actbad, self.act)
      end

      puts ret if ret.is_a? String
    end



    def get_system_action
      if self.pipe_to == :open
        ret = Proc.new { |val| val.open }
      else
        ret = Proc.new { |val| val.copy }
      end

      return ret
    end


  end
end




# Run it.
Bm::Hub.with ARGV
exit
