#!/usr/bin/env ruby

#
# Simple Text Archiving and Retrieving
#
# For a quick intro, type `star -h`.
#


module Star
  class Hub


    # If it weren't for this one, all would be nothing.
    def self.with( args = [ ] )
      Star::Hub.require_files
      star = Star::Hub.new args
      star.main
    end


    def self.require_files
      Star::Hub.required_files.each do |req|
        req = "#{__dir__}/src/#{req}"
        if File.exists? req
          require_relative req
        else
          raise Exception.new("Can't run star: missing required file '#{req}'.")
        end
      end
    end


    def self.required_files
      %w{ args.rb config.rb demo.rb etc.rb fileutils.rb line.rb lines.rb metadata.rb message.rb store.rb tags.rb utils.rb value.rb }
    end




    def initialize( args = [ ], demo = nil )
      @config = (demo.nil?) ? Star::Config.new : Star::Config.new(demo)

      argh = Star::Args.parse(args, demo, @config)
      @act, @args, @filter_mode = argh[:act], argh[:args], argh[:filtmode]

      @store = Star::Store.new @config

      @lines = Star::Lines.new self
    end

    attr_reader :act, :args, :config, :filter_mode
    attr_accessor :lines, :store



    def main
      if ((self.act == :copy) or
          (self.act == :open) or
          (self.act == :delete))
        self.lines.cull

      elsif self.act == :commands
        puts Star::Message.show_commands

      elsif self.act == :demo
        Star::Demo.run(self.args)

      elsif self.act == :demodup
        puts Star::Message.out(:demodup)

      elsif self.act == :err
        puts Star::Message.out(:argsbad, true)

      elsif self.act == :examples
        puts Star::Message.show_examples

      elsif self.act == :help
        puts Star::Message.help_msg

      elsif self.act == :helpx
        puts Star::Message.help_msg + "\n" + Star::Message.extra_notes

      elsif self.act == :init
        self.config.save_settings
        self.store.init_file

      elsif self.act == :new
        Star::Line.new_from_args self

      elsif self.act == :readx
        puts Star::Message.readme + "\n" + Star::Message.extra_notes

      elsif self.act == :tags
        self.store.print_tags_report

      else   # Strange fire.
        puts Star::Message.out(:actbad, self.act)
      end
    end



    def filter_inclusive?
      if self.filter_mode == :loose then true else nil end
    end


  end
end




# Run it.
Star::Hub.with ARGV
exit
