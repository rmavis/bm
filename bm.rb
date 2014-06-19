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
  def self.backup_file_name
    return BM.file_name + ".bk"
  end

  def self.file_path
    return File.expand_path(BM.file_name)
  end
  def self.backup_file_path
    return File.expand_path(BM.backup_file_name)
  end

  def self.has_file?
    if File.file?(BM.file_path) then true else nil end
  end
  def self.has_backup_file?
    if File.file?(BM.backup_file_path) then true else nil end
  end

  def self.file_empty?
    if File.zero?(BM.file_path) then true else nil end
  end
  def self.backup_file_empty?
    if File.zero?(BM.backup_file_path) then true else nil end
  end

  def self.line_sep
    return ""  # The ASCII record separator character.
  end
  def self.tag_sep
    return ""  # The ASCII unit separator character.
  end

  def self.escapes
    return ["`", '"']
  end

  def self.make_backup_file
    IO.copy_stream(BM.file_path, BM.backup_file_path)
  end
  def self.delete_backup_file
    File.delete(BM.backup_file_path)
  end


  def self.help_msg
    ret = <<END
#{"bm".bold} is a tool for saving and copying bits of text.
You can use it to save bookmarks, hard-to-remember commands, complex
emoticons, stuff like that.

Say you want to save Wikipedia's page on Tardigrades. You would type:
bm -n https://en.wikipedia.org/wiki/Tardigrade

You can tag text by entering words before the bit you want to save.
Say you want to tag Wikipedia's page on the Flammarion Engraving
"wiki" and "art". You would type:
bm -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

To see all your saves, you would type:
bm -a

To see all your saves tagged "music", you would type:
bm music

If there are more than one saves that match the tag, you'll be shown
a numbered list of them and prompted for the one you want. The text
on the numbered line will be copied to your clipboard. Tags will be
listed beneath the numbered line. And if there's only one match,
you'll skip the browsing step.

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
    @has_file, @nil_file = nil, nil
    self.check_file!

    argh = self.parse_args(args)
    @act, @args = argh[:act], argh[:args]
    @lines, @line, @val, argh = [ ], nil, nil, nil
  end

  attr_reader :act, :args
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
      elsif ((x == "--delete") or (x == "--del") or (x == "-d"))
        ret[:act] = :del
        # Could add a -e flag for editing? #HERE.
      elsif (x.match(/-.*?/))
        ret[:act] = :err
      else
        ret[:act] = :filt
      end

      # These do not want the first argument.
      if ((ret[:act] == :all) or (ret[:act] == :new) or (ret[:act] == :del))
        args.delete_at(0)
      end

      # These want the arguments.
      if ((ret[:act] == :filt) or (ret[:act] == :new) or (ret[:act] == :del))
        ret[:args] = args
      end
      # Unless deleting, filtering, or showing all, the arguments are discarded.
    end

    return ret
  end



  def check_file!
    self.has_file, self.nil_file = BM.has_file?, BM.file_empty?
  end




  def main
    ret = nil

    if (self.act == :help)
      ret = BM.help_msg

    elsif (self.act == :init)
      ret = self.init_file

    elsif (self.act == :new)
      ret = self.new_line

    elsif ((self.act == :filt) or
           (self.act == :all))
      ret = self.cull_lines

    elsif (self.act == :del)
      ret = self.delete_lines

    elsif (self.act == :err)
      ret = self.out_msg(:argsbad)

    else   # Strange fire.
      ret = self.out_msg(:actbad)
    end

    puts ret
  end





  # When the action is init, main calls this.
  def init_file
    if self.has_file
      if self.nil_file
        ret = self.out_msg(:fileempty)
      else
        ret = self.out_msg(:fileexists)
      end
    else
      if self.make_file
        ret = self.out_msg(:init)
      else
        ret = self.out_msg(:filefail)
      end
    end

    return ret
  end




  def make_file
    f = File.new(BM.file_path, 'w+', 0600)
    self.check_file!  # Updates the @has_file and @nil_file bools.
    return self.has_file
  end





  # When the action is to create a new line, main calls this.
  def new_line
    if self.args.empty?
      ret = self.out_msg(:argsno)

    else
      ret = (self.has_file) ? "\n" : self.init_file
      self.line_from_args!
      self.chop_val!

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
      fh = File.open(BM.file_path, 'a+')
      if self.nil_file
        fh.puts str
      else
        fh.puts BM.line_sep + "\n" + str
      end
      fh.close
      ret = true
    end

    return ret
  end



  def write_lines(lines = self.lines)
    ret = nil

    if self.has_file
      fh, n, m = File.open(BM.file_path, 'w'), 0, lines.length
      lines.each do |line|
        fh.puts line  # The escape is unnecessary.
        n += 1
        fh.puts BM.line_sep if (n < m)
      end
      fh.close
      ret = true
    end

    return ret
  end




  def line_from_args!(arr = self.args)
    ret = nil

    if arr.is_a? Array
      ret = (arr.empty?) ? nil : self.escape(arr.join(BM.tag_sep))
    end

    self.line = ret
    return self.line
  end




  def line_to_parts(str = self.line)
    ret = { :val => '', :tags => [ ] }

    arr = str.gsub(BM.line_sep, '').split(BM.tag_sep)
    ret[:val] = arr.pop
    ret[:tags] = arr

    return ret
  end



  def escape(str = self.line)
    ret = str
    BM.escapes.each do |esc|
      ret = ret.gsub(esc){ "\\#{esc}" }
    end
    return ret
  end

  def clean(str = self.line)
    ret = str
    BM.escapes.each do |esc|
      ret = ret.gsub("\\#{esc}"){ esc }
    end
    return ret
  end




  # When the action is to cull a line, main calls this.
  def cull_lines
    self.read_lines!

    if self.lines.empty?
      ret = self.why_no_lines?
    else
      self.get_wanted_line!
      if self.line.nil?
        ret = self.out_msg(:valnah)
      else
        self.chop_val!
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




  # When the action is to delete a line, main calls this.
  def delete_lines
    self.read_lines!

    if self.lines.empty?
      ret = self.why_no_lines?
    else
      self.get_wanted_line!
      if self.line.nil?
        ret = self.out_msg(:delnah)
      else
        self.chop_val!
        self.read_lines!([ ])  # Reads the whole file.
        self.remove_line!
        BM.make_backup_file
        if self.write_lines
          BM.delete_backup_file
          ret = self.out_msg(:delok, self.clean(self.val))
        else
          ret = self.out_msg(:delfail, true)
        end
      end
    end

    return ret
  end




  def remove_line!(line = self.line, lines = self.lines)
    ret = [ ]
    lines.each { |chk| ret.push(chk) if !chk.eql?(line) }
    self.lines = ret
    return ret
  end




  # Provides a reason why there are no lines.
  # Mostly here because the same block would be used in multiple methods.
  def why_no_lines?
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

    return ret
  end




  # Reads the file.
  # Filters lines from the file that match the @args.
  # Fills in the @lines array.
  def read_lines!(filts = self.args)
    ret = [ ]

    if ((self.has_file) and (!self.nil_file))
      fh = File.open(BM.file_path, 'r')

      if filts.empty?
        while line = fh.gets(BM.line_sep)
          l = line.chomp(BM.line_sep).strip
          ret.push(l) if !l.empty?
        end

      else
        # Because they're stored escaped.
        filts.collect! { |filt| self.escape(filt) }
        while line = fh.gets(BM.line_sep)
          line = line.chomp(BM.line_sep).strip
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

    # This sorting sucks. #HERE
    ret = ret.uniq.sort if (!ret.empty?)
    self.lines = ret
    return self.lines
  end




  def get_wanted_line!
    if self.lines.empty?
      ret = nil
    else
      # If only one line matches, skip the browsing step.
      if ((self.act == :filt) and (self.lines.count == 1))
        ret = self.lines[0]
      else
        ret = self.which_line?
      end
    end

    self.line = ret
    return self.line
  end



  def which_line?
    self.print_lines
    ret = self.prompt_for_line
    return ret
  end



  def print_lines
    n, x = 1, self.lines.count.to_s.length

    self.lines.each do |line|
      parts = self.line_to_parts(line)
      y = x - n.to_s.length
      spc = (y > 0) ? (' ' * y) : ''
      pre = "#{spc}#{n})"
      puts "#{pre} #{self.clean(parts[:val])}"
      if !parts[:tags].empty?
        spc = ' ' * (pre.length)
        puts "#{spc} Tags: #{self.clean(parts[:tags].join(', '))}"
      end
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
  def chop_val!
    ret, str = nil, self.line

    if str.is_a? String
      ret = (str.include? BM.tag_sep) ? str.split(BM.tag_sep).last : str
      ret = ret.strip
    end

    self.val = ret
    return self.val
  end




  def copy_val(str = self.val)
    return nil if !str.is_a? String

    #oks = self.escape(str.gsub(/%/, '%%'))
    oks = str.gsub(/%/, '%%')
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
    elsif (x == :delfail)
      ret = "Something went wrong with deleting the line."
      ret << " A backup file was created at \"#{BM.backup_file_name}\"." if v
    elsif (x == :delnah)
      ret = "Nevermind? Okay."
    elsif (x == :delok)
      ret = (v.nil?) ? "Consider it gone." : "Deleted \"#{v}\"."
    elsif (x == :fileempty)
      ret = "#{BM.file_name} is empty. You can add lines with \"bm -n what ever\"."
    elsif (x == :fileexists)
      ret = "#{BM.file_name} already exists."
    elsif (x == :filefail)
      ret = "Failed to create #{BM.file_name} :("
    elsif (x == :fileno)
      ret = "Can't read #{BM.file_name} because it doesn't exist. Run \"bm -i\"?"
    elsif (x == :init)
      ret = "Created #{BM.file_name}."
    elsif (x == :linesno)
      ret = "#{BM.file_name} has no valid lines."
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
