#!/usr/bin/ruby

#
# For a quick intro, type "bm -h".
#


module BM
  class Config < BM::BM

    #
    # Customization variables.
    # If you want to change the default file, filter mode, or system call,
    # then change the value of one of these methods.
    #

    def self.file_name
      "~/.bm"
    end

    # This should be either :strict or :loose.
    def self.default_filter_mode
      :strict
    end

    # This should be either :copy or :open.
    def self.default_pipe_to
      :copy
    end


  end
end



# Run it.
require 'src/start.rb'
BM::Start.with ARGV
exit
