#
# It's all happening.
#


module BM
  class Start < BM::BM


    # If it weren't for this one, all would be nothing.
    def self.with( args = [ ] )
      BM::Start.require_files
      bm = BM::BM.new args
      bm.main
    end



    def self.required_files
      %w{ args.rb demo.rb etc.rb line.rb lines.rb metadata.rb message.rb store.rb tags.rb utils.rb value.rb }
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


  end
end
