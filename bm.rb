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
      @act, @args, @filter_mode = argh[:act], argh[:args], argh[:filtmode]

      f_name = (demo.nil?) ? Bm::Config.file_name : Bm::Demo.file_name
      @store = Bm::Store.new(f_name)

      @lines = Bm::Lines.new self
    end

    attr_reader :act, :args, :filter_mode
    attr_accessor :store, :lines



    def main
      if ((self.act == :copy) or
          (self.act == :open) or
          (self.act == :delete))
        self.lines.cull

      elsif self.act == :commands
        puts Bm::Message.show_commands

      elsif (self.act == :demo)
        ret = Bm::Demo.run(self.args)

      elsif (self.act == :demodup)
        ret = Bm::Message.out(:demodup)

      elsif self.act == :err
        puts Bm::Message.out(:argsbad, true)

      elsif self.act == :examples
        puts Bm::Message.show_examples

      elsif self.act == :help
        puts Bm::Message.help_msg

      elsif self.act == :helpx
        puts Bm::Message.help_msg + "\n" + Bm::Message.extra_notes

      elsif self.act == :init
        self.store.init_file

      elsif self.act == :new
        Bm::Line.new_from_args self

      elsif self.act == :tags
        self.store.print_tags_report

      else   # Strange fire.
        puts Bm::Message.out(:actbad, self.act)
      end
    end



    def filter_inclusive?
      if self.filter_mode == :loose then true else nil end
    end


  end
end




# Run it.
Bm::Hub.with ARGV
exit
