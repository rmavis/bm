#
# Methods for the demo.
# To run it, prepend "--demo" to any normal string of arguments.
# Such as "star --demo -a" or "star --demo -o book".
#


module Star
  class Demo < Star::Hub


    def self.file_path
      "~"
    end

    def self.file_name
      ".star.store.demo"
    end

    def self.file
      File.expand_path(Star::Demo.file_path + '/' + Star::Demo.file_name)
    end


    def self.config_settings
      {
        :file_name => Star::Demo.file,
        :filter_mode => Star::Config.default_filter_mode,
        :pipe_to => Star::Config.default_pipe_to
      }
    end



    def self.filler_lines
      return [
        ['art', 'NASA', 'space', 'http://settlement.arc.nasa.gov/70sArtHiRes/70sArt/art.html'],
        ['art', 'design', 'https://en.wikipedia.org/wiki/El_Lissitzky'],
        ['awesome', 'book', 'creepy', 'https://en.wikipedia.org/wiki/House_of_Leaves'],
        ['awesome', 'book', 'nerdy', 'https://en.wikipedia.org/wiki/Cryptonomicon'],
        ['book', 'ruby', 'why', 'http://mislav.uniqpath.com/poignant-guide/'],
        ['demo', 'ruby', 'why', 'http://tryruby.org/levels/1/challenges/0'],
        ['design', 'Experimental Jetset', 'web design', 'http://www.experimentaljetset.nl/'],
        ['machinefabriek', 'music', 'web design', 'http://www.machinefabriek.nu/'],
        ['music', 'Nils Frahm', 'Screws', 'http://screws.nilsfrahm.com/'],
        ['OS X', 'utility', 'clipboard', 'Flycut', 'https://github.com/TermiT/Flycut/']
      ]
    end



    def self.run( args = [ ] )
      Star::Demo.new(args).main
    end





    def initialize( args )
      @hub = Star::Hub.new(args, Star::Demo.config_settings)
    end

    attr_accessor :hub



    def main
      self.start!

      if self.hub.store.has_file
        puts self.out_msg(:start, self.hub.store.has_file?)

        self.hub.main

        if self.stop?
          puts self.out_msg(:done, self.hub.store.has_file?)
        else
          puts self.out_msg(:delfail)
        end

      else
        puts self.out_msg(:startfail)
      end
    end



    def start!
      self.hub.store.make_file
      if self.hub.store.has_file
        self.write_lines
        self.hub.store.check_file!
      end
    end



    def write_lines
      Star::Demo.filler_lines.each do |arr|
        line = Star::Line.new
        line.fill_from_array arr
        self.hub.store.append? line
      end
    end



    def stop?
      if self.hub.store.has_file?
        File.delete(self.hub.store.file)
        self.hub.store.check_file!
        ret = (self.hub.store.has_file) ? nil : true
      else
        ret = true
      end

      puts self.out_msg(:delok) if ret

      return ret
    end



    # Messages unique to the demo.
    def out_msg( x = :bork, v = nil )
      x = :bork if !x.is_a? Symbol

      if x == :delfail
        ret = "Failed to delete the demo file, #{self.hub.store.file}. Lame."

      elsif x == :delok
        ret = "\nDelete the demo file, #{self.hub.store.file}."

      elsif x == :done
        if v.nil?
          ret = "\nAnd that's how it works! To get started, type \"star -i\", or add a line with something like \"star -n what ever\"."
        else
          ret = "\nRemoved the demo file, #{self.hub.store.file}."
        end

      elsif x == :start
        ret = "This is a demo. It is using a demo file at #{self.hub.store.file}.\n\n"

      elsif x == :startfail
        ret = "Unable to run the demo :("

      else
        ret = Star::Message.out(x, v)
      end

      return ret
    end


  end
end
