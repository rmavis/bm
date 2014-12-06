#
# Configuration variables.
#
# If you want to change the default file, filter mode, or system call,
# then change the value of one of these methods.
#



module Star
  class Config


    # This needs to include the path.
    def self.file_name
      "store"
    end


    # This should be either `:strict` or `:loose`.
    def self.filter_mode
      :strict
    end


    # This should be either `:copy` or `:open`.
    def self.pipe_to
      :copy
    end


  end
end
