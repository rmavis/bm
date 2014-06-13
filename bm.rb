#!/usr/bin/ruby

#
# For a quick intro, type "bm -h".
#



class BM


  #
  # Class methods.
  #

  def self.file_name
    return "~/.bm"
  end
  def self.file_path
    return File.expand_path(BM.file_name)
  end

  def self.line_separator
    return ""  # The ASCII record separator character.
  end
  def self.tag_separator
    return ""  # The ASCII unit separator character.
  end

  def self.line_pattern
    return Regexp.new(BM.line_separator + '.*' + BM.line_separator)
  end

  def self.escapes
    return ["`", '"']
  end


  # The help message. It should be made more helpful. #HERE
  def self.help_msg
    ret = <<END
#{"bm".bold} is a tool for saving and copying bits of text.
You can use it to save bookmarks, hard-to-remember commands, complex
emoticons, things like that.

Say you want to save Wikipedia's page on the Flammarion Engraving.
You would type:
bm -n http://en.wikipedia.org/wiki/Flammarion_engraving

You can tag text by entering words before the bit you want to save.
Say you want to tag the Flammarion Engraving URL "wiki" and "art".
You would type:
bm -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

To see all your saved bits, you would type:
bm -a

To see all your saved bits tagged "art", you would type:
bm art

If there are more than one lines that match the tag, you'll be shown
a numbered list of them and prompted for the one you want. The non-
tag portion of the line will be copied to your clipboard. If there's
only one match, you'll skip the browsing step.

#{"bm".bold} saves your text in a plain text file at #{BM.file_name}, so you can add
and remove lines or edit values in your editor of choice. But be
warned: it uses the non-printable ASCII record and unit separator
characters, so edit with care.
END
    return ret
  end





  #
  # Instance methods.
  #

  def initialize(args = [ ])
    @filename, @filepath = BM.file_name, BM.file_path
    @linesep, @tagsep = BM.line_separator, BM.tag_separator
    @linepattern, @escapes = BM.line_pattern, BM.escapes

    @has_file, @nil_file = self.has_file?, self.nil_file?

    argh = self.parse_args(args)
    @act, @args = argh[:act], argh[:args]
    @lines, @line, @val, argh = [ ], nil, nil, nil
  end

  attr_reader :act, :args, :filename, :filepath, :linesep, :tagsep, :linepattern, :escapes
  attr_accessor :lines, :line, :val, :has_file, :nil_file




  # Pass this the arguments array (argv) and it will return
  # a hash containing two keys:
  # - act, indicating the action for the main routine to take
  # - args, which are the arguments for the specified action
  # If the argv contains flags in addition to tags or terms,
  # then the flags will not be be included in the returned args array.
  def parse_args(args = [ ])
    ret = {:act => :help, :args => [ ]}

    # If there are no args, assume help is needed.
    if ((!args.is_a? Array) or ((args.is_a? Array) and (args.empty?)))
      ret[:act] = :help

    else
      # Parse the action first.
      x = args[0].to_s.downcase.strip
      if ((x == "--init") or (x == "-i"))
        ret[:act] = :init
      elsif ((x == "--help") or (x == "-h"))
        ret[:act] = :help
      elsif ((x == "--all") or (x == "-a"))
        ret[:act] = :all
      elsif ((x == "--new") or (x == "-n"))
        ret[:act] = :new
        # Could add a -e flag for editing? #HERE.
        # And one for deleting?
      elsif (x.match(/-.*?/))
        ret[:act] = :err
      else
        ret[:act] = :filt
      end

      if ((ret[:act] == :new) or (ret[:act] == :all) or (ret[:act] == :filt))
        args.delete_at(0) if ((ret[:act] == :new) or (ret[:act] == :all))
        ret[:args] = args
      end
      # Unless filtering or showing all, the arguments are discarded.
    end

    return ret
  end




  def has_file?
    if File.file?(self.filepath) then true else nil end
  end

  def nil_file?
    if File.zero?(self.filepath) then true else nil end
  end

  def check_file!
    self.has_file, self.nil_file = self.has_file?, self.nil_file?
  end




  def main
    ret = nil

    if (self.act == :help)
      ret = BM.help_msg

    elsif (self.act == :init)
      ret = self.init_file

    elsif (self.act == :new)
      ret = self.new_line

    elsif ((self.act == :filt) or (self.act == :all))
      ret = self.cull_lines

    elsif (self.act == :err)
      ret = self.out_msg(:argsbad)

    else   # Strange fire.
      ret = self.out_msg(:actbad)
    end

    puts ret
  end





  # When the action is init, main calls this.
  def init_file
    self.check_file!

    if self.has_file
      if self.nil_file
        ret = self.out_msg(:fileempty)
      else
        ret = self.out_msg(:fileexists)
      end
    else
      if self.make_file!
        ret = self.out_msg(:init)
      else
        ret = self.out_msg(:filefail)
      end
    end

    return ret
  end




  # Creates the file.
  def make_file!
    if self.has_file
      ret = nil
    else
      f = File.new(self.filepath, 'w+', 0600)
      self.check_file!  # Updates the @has_file and @nil_file bools.
      ret = self.has_file
    end

    return ret
  end





  # When the action is to create a new line, main calls this.
  def new_line
    if self.args.empty?
      ret = self.out_msg(:argsno)

    else
      ret = (self.has_file) ? "\n" : self.init_file
      self.line, self.val = self.line_from_args, self.args.last

      if self.write_line
        ret << "\n" + self.out_msg(:saveok)
        if self.copy_val
          ret << "\n" + self.out_msg(:pipeok, self.clean(self.val))
        else
          ret << "\n" + self.out_msg(:pipefail)
        end
      else
        ret << "\n" + self.out_msg(:savefail)
      end

      ret = ret.strip
    end

    return ret
  end



  def write_line(str = self.line)
    ret = nil

    if self.has_file
      fh = File.open(self.filepath, 'a+')
      if self.nil_file
        fh.puts self.escape(str)
      else
        fh.puts self.linesep + self.escape(str)
      end
      fh.close
      ret = true
    end

    return ret
  end



  def line_from_args(arr = self.args)
    ret = nil

    if arr.is_a? Array
      ret = (arr.empty?) ? nil : arr.join(self.tagsep)
    end

    return ret
  end





  # This strips slashes and separators and such for pretty printing.
  def beautify(str = self.line)
    str = str.gsub(self.linesep, '').gsub(self.tagsep, ' : ')
    return self.clean(str)
  end

  def escape(str = self.line)
    ret = str
    self.escapes.each do |esc|
      ret = ret.gsub(esc){ "\\#{esc}" }
    end
    return ret
  end

  def clean(str = self.line)
    ret = str
    self.escapes.each do |esc|
      ret = ret.gsub("\\#{esc}"){ esc }
    end
    return ret
  end





  # When the action is to cull a line, main calls this.
  def cull_lines
    self.read_lines

    if self.lines.empty?
      if self.has_file
        if self.nil_file
          ret = self.out_msg(:fileempty)
        elsif self.args.empty?
          ret = self.out_msg(:linesno)
        else
          ret = self.out_msg(:matchno)
        end
      else
        ret = self.out_msg(:fileno)
      end
    else
      self.get_wanted_line
      if self.line.nil?
        ret = self.out_msg(:valnah)
      else
        self.chop_val
        if (self.val.nil?)
          ret = self.out_msg(:valno)
        else
          pchk = self.copy_val
          if pchk.nil?
            ret = self.out_msg(:pipefail)
          else
            ret = self.out_msg(:pipeok, self.clean(self.val))
          end
        end
      end
    end

    return ret
  end




  # Reads the file.
  # Filters lines from the file that match the @args.
  # Fills in the @lines array.
  def read_lines(filts = self.args)
    ret = [ ]

    self.check_file!
    if ((self.has_file) and (!self.nil_file))
      fh = File.open(self.filepath, 'r')

      if filts.empty?
        while line = fh.gets(self.linesep)
          l = line.chomp(self.linesep).strip
          ret.push(l) if !l.empty?
        end

      else
        while line = fh.gets(self.linesep)
          line = line.chomp(self.linesep).strip
          if !line.empty?
            cmp, good = line.downcase, nil
            filts.each do |filt|
              good = true if (cmp.include? filt.downcase)
            end
            ret.push(line) if good
          end
        end
      end

      fh.close
    end

    ret = ret.uniq.sort if (!ret.empty?)
    self.lines = ret
  end




  def get_wanted_line
    if self.lines.empty?
      self.line = nil
    else
      # If only one line matches, skip the browsing step.
      if ((self.act == :filt) and (self.lines.count == 1))
        self.line = self.lines[0]
      else
        self.line = self.which_line?
      end
    end
  end



  def which_line?
    self.print_lines
    ret = self.prompt_for_line
    return ret
  end



  def print_lines
    n, x = 1, self.lines.count.to_s.length

    self.lines.each do |line|
      y = x - n.to_s.length
      y.times { print ' ' } if (y > 0)
      puts "#{n}) #{self.beautify(line)}"
      n += 1
    end
  end



  def prompt_for_line(inc0 = true)
    c = (self.lines.count.to_s.length - 1)
    spc = (c > 0) ? (' ' * c) : ''
    puts "#{spc}0) None." if inc0
    print "#{spc}?: "

    x = STDIN.gets.chomp().gsub(/[^0-9]+/, '').to_i
    if (x == 0)
      ret = nil
    elsif (x <= self.lines.count)
      ret = self.lines[(x - 1)]
    else
      puts "Bad choice. Try again."
      ret = self.prompt_for_line(nil)
    end

    return ret
  end




  # This parses the value field from the given line.
  def chop_val(str = self.line)
    ret = nil

    if str.is_a? String
      ret = (str.include? self.tagsep) ? str.split(self.tagsep).last : str
      ret = self.clean(ret.strip)
    end

    self.val = ret
  end




  def copy_val(str = self.val)
    return nil if !str.is_a? String

    oks = self.escape(str.gsub(/%/, '%%'))
    chk = system("printf \"#{oks}\" | pbcopy")
    ret = (chk) ? true : nil

    return ret
  end





  # Returns a message according to the given key.
  def out_msg(x = :bork, v = nil)
    x = :bork if !x.is_a? Symbol

    if (x == :actbad)
      ret = "Invalid action. Strange fire."
    elsif (x == :argsbad)
      ret = "Bad arguments, friendo. Maybe check the help message? \"bm -h\"."
    elsif (x == :argsno)
      ret = "No arguments. Try something like \"bm good stuff\"."
    elsif (x == :fileempty)
      ret = "#{self.filename} is empty. You can add lines with \"bm -n what ever\"."
    elsif (x == :fileexists)
      ret = "#{self.filename} already exists."
    elsif (x == :filefail)
      ret = "Failed to create #{self.filename} :("
    elsif (x == :fileno)
      ret = "Can't read #{self.filename} because it doesn't exist. Run \"bm -i\"?"
    elsif (x == :init)
      ret = "Created #{self.filename}."
    elsif (x == :linesno)
      ret = "#{self.filename} has no valid lines."
    elsif (x == :matchno)
      ret = "No lines match."
    elsif (x == :pipefail)
      ret = "Failed to copy value to clipboard. WTF?"
    elsif (x == :pipeok)
      ret = (v.nil?) ? "Good good." : "Copied \"#{v}\"."
    elsif (x == :savefail)
      ret = "Failed to save new line :("
    elsif (x == :saveok)
      ret = "Save new line."
    elsif (x == :valnah)
      ret = "Nothing wanted, nothing copied."
    elsif (x == :valno)
      ret = "Unable to find the value on \"#{self.line}\"."
    else
      ret = "Error: something unknown is doing we don't know what."
    end

    return ret
  end

end





# Clipped this from:
# http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\033[0m" end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end





# Run it.
BM.new(ARGV).main
exit
