#!/usr/bin/ruby

#
# For a quick intro, type "bm -h".
#


class BM


  #
  # Class methods.
  #


  # =begin Customization variables.
  # If you want to change the default file, filter mode, or system call,
  # then change the value of one of these methods.

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

  # =end Customization variables.



  def self.file_path
    File.expand_path(BM.file_name)
  end

  def self.has_file?
    if File.file?(BM.file_path) then true else nil end
  end


  def self.backup_ext
    ".bk"
  end

  def self.demo_ext
    ".demo"
  end

  def self.backup_file_name(ext = BM.backup_ext)
    BM.file_name + ext
  end

  def self.backup_file_path(ext = BM.backup_ext)
    File.expand_path(BM.backup_file_name(ext))
  end


  # The ASCII record separator character.
  def self.line_sep
    ""
  end

  # The ASCII unit separator character.
  def self.tag_sep
    ""
  end

  # Characters that need to be escaped.
  def self.escapes
    ["`", '"']
  end



  def self.help_msg
    ret = <<END
#{"Readme".header}
  #{"bm".syscmd} is a simple tool for saving and retrieving bits of text. You
  could use it to save bookmarks, hard-to-remember commands, complex
  emoticons, stuff like that.

  Say you want to save Wikipedia's page on Tardigrades. You would enter:
    $ bm -n https://en.wikipedia.org/wiki/Tardigrade

  Then, when you want to read about those creepy cool animals again, you
  can type:
    $ bm Tardigrade
  And, assuming you haven't saved anything else that includes the word
  "Tardigrade", #{"bm".syscmd} will copy the URL to your clipboard. Or you can type:
    $ bm -o Tardigrade
  and the URL will be opened in your default browser.

  To help with retrieving things later, you can tag can your saves by
  entering words before the value you want to copy or open. So say you
  want to save Wikipedia's page on the Flammarion Engraving and tag it
  "wiki" and "art":
    $ bm -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

  To see all your saves tagged "wiki":
    $ bm wiki

  To see all your saves tagged both "wiki" and "art":
    $ bm wiki art

  If there are more than one saves that match the tags, then you'll be
  shown a numbered list of them and prompted for the one you want. The
  text on the numbered line will be copied to your clipboard. Tags will
  be listed beneath the numbered line. And if there's only one match,
  you'll skip the browsing step.

  #{"bm".syscmd} saves your text in a plain text file at #{BM.file_name}, so you can add,
  edit, and remove values in your editor of choice. You can also delete
  values with:
    $ bm -d

  To see a list of commands:
    $ bm -c

  And to run a little demo:
    $ bm --demo

END
    return ret
  end



  def self.show_commands
    ret = <<END
#{"Flags".header}
  -a, --all        Show all saves.
  -c, --commands   Show this message.
  -d, --delete     Delete a save.
  -i, --init       Create the #{BM.file_name} file.
  -l, --loose      Match loosely, rather than strictly.
  -m, --demo       Run the demo.
  -n, --new        Add a new line.
  -o, --open       #{"open".syscmd} the value rather than #{"pbcopy".syscmd} it.
  -p, --copy       #{"pbcopy".syscmd} the value rather than #{"open".syscmd} it.
  -r, --readme,
    -h, --help     Show the readme message.
  -s, --strict     Match strictly rather than loosely.
  -t, --tags       Show all tags.
  -x, --examples   Show some examples.
  -xr, -rx,
    -xh, -hx       Show the readme message with extra details.

END
    return ret
  end



  def self.show_examples
    ret = <<END
#{"Examples".header}
  #{"bm -a".bmcmd}
     See a numbered list of all your saves. You'll be prompted to enter
     the number of the line you want. That line will be piped to #{"pbcopy".syscmd},
     thereby copying it to your clipboard.

  #{"bm -n music \"Nils Frahm\" Screws http://screws.nilsfrahm.com/".bmcmd}
     Save a new line to your #{BM.file_name}. The URL is the value that will be
     piped to #{"pbcopy".syscmd} or passed to #{"open".syscmd}. The other parts of the line are
     the tags, which will be checked when you run other commands.

  #{"bm music".bmcmd}
     See a numbered list of your saves tagged "music". As with #{"bm -a".bmcmd},
     you'll be prompted to enter the number of the line you want piped
     to #{"pbcopy".syscmd}. If only one value matches, you won't be prompted for a
     line. See the important note before.

  #{"bm weird music".bmcmd}
     Identical to #{"bm music".bmcmd} but the list will show your saves
     tagged both "weird" and "music".

  #{"bm -l weird music".bmcmd}
     Identical to #{"bm music".bmcmd} but the list will show your saves
     tagged either "weird" or "music".

  #{"bm -o music".bmcmd}
     Identical to #{"bm music".bmcmd} but the value on the line you enter will be
     passed to #{"open".syscmd}. So URLs should open in your default browser, files
     and directories should #{"open".syscmd} as expected, etc.

  #{"bm -d music".bmcmd}
     Identical to #{"bm music".bmcmd} but the value on the line you enter will be
     deleted from your #{BM.file_name}.

END
    return ret + "\n" + BM.imp_note
  end



  def self.imp_note
    ret = <<END
#{"Important".header}
  If only one save matches the tags you specify, then you will not be
  shown a numbered list of matches. Instead, that step will be skipped
  and the value will be copied, opened, or deleted accordingly.

  So if only one save is tagged "music", then #{"bm -o music".bmcmd} will pass
  the matching value to #{"open".syscmd}, and #{"bm -d music".bmcmd} will delete the save
  from your #{BM.file_name}.

END
    return ret
  end



  def self.extra_notes
    ret = <<END
#{"Extra".header}
  If you feel list customizing #{"bm".syscmd}, there are three class methods toward
  the top of the file that you can change:
    1. The file name, #{BM.file_name}, is specified in BM::file_name
       If you change this, make sure you have write privileges.
    2. The default filter mode is specified in BM::default_filter_mode
       The value should be a symbol, either :strict or :loose
    3. The default system action is specified in BM::default_pipe_to
       The value should be a symbol, either :copy or :open

  #{"bm".syscmd} uses the non-printing ASCII record and unit separator characters
  when saving your data. The record separator separates each "line". Each
  line holds the value that will be copied or opened along with any tags.
  If there are tags, they will be separated from the value and from each
  other by the unit separator. The value is the last slot in that line.
  Something like this:
    https://en.wikipedia.org/wiki/Tardigrade
    #{"^^".red}
    music#{"^_".red}Nils Frahm#{"^_".red}Screws#{"^_".red}http://screws.nilsfrahm.com/
    #{"^^".red}
    wiki#{"^_".red}art#{"^_".red}http://en.wikipedia.org/wiki/Flammarion_engraving

  So if you want to edit the file in your editor of choice, beware that
  your editor might not display those characters, or might display them
  weirdly. In #{"emacs".syscmd}, you can enter the record separator with:
    C-q 036 <RET>
  And the unit separator with:
    C-q 037 <RET>

END
    return ret
end





  #
  # Instance methods.
  #

  def initialize(args = [ ], demo = nil)
    argh = self.parse_args(args, demo)
    @act, @args, @filter_mode, @pipe_to = argh[:act], argh[:args], argh[:filtmode], argh[:pipeto]
    argh = nil

    if demo.nil?
      @file_name, @file_path = BM.file_name, BM.file_path
    else
      @file_name, @file_path = BM.backup_file_name(BM.demo_ext), BM.backup_file_path(BM.demo_ext)
    end

    @has_file, @nil_file, @bk_file = nil, nil, nil
    self.check_file!

    @lines, @tags, @line, @val = [ ], [ ], nil, nil
    @sysact = self.get_system_action
  end

  attr_reader :act, :args, :file_name, :file_path, :filter_mode, :pipe_to, :sysact
  attr_accessor :lines, :tags, :line, :val, :has_file, :nil_file, :bk_file



  # Pass this the arguments array (argv) and it will return a
  # hash containing four keys:
  # - :act, indicating the action for the main routine to take
  # - :args, which are the arguments for the specified action
  # - :filtmode, which, if not specified on the command line,
  #    will be the class default
  # - :pipeto, which acts akin to :filtmode
  def parse_args(args = [ ], demo = nil)
    ret = {
      :act => nil, :args => [ ],
      :pipeto => BM.default_pipe_to,
      :filtmode => BM.default_filter_mode
    }

    # If there are no args, assume help is needed.
    if ((!args.is_a? Array) or ((args.is_a? Array) and (args.empty?)))
      ret[:act] = (demo.nil?) ? :commands : :read

    else
      wantargs = true

      while args[0].is_a? String and args[0].match(/^-+[a-z]+/)
        x = args[0].downcase.strip

        if ((x == "-a") or (x == "--all"))
          ret[:act], wantargs = :read, nil
        elsif ((x == "-c") or (x == "--commands"))
          ret[:act], wantargs = :commands, nil
        elsif ((x == "-d") or (x == "--delete"))
          ret[:act] = :delete
        elsif ((x == "-i") or (x == "--init"))
          ret[:act] = :init
        elsif ((x == "-l") or (x == "--loose"))
          ret[:filtmode] = :loose
        elsif ((x == "-m") or (x == "--demo"))
          ret[:act] = :demo
        elsif ((x == "-n") or (x == "--new"))
          ret[:act] = :new
        elsif ((x == "-o") or (x == "--open"))
          ret[:pipeto] = :open
        elsif ((x == "-p") or (x == "--copy"))
          ret[:pipeto] = :copy
        elsif ((x == "-r") or (x == "--readme") or
               (x == "-h") or (x == "--help"))
          ret[:act], wantargs = :help, nil
        elsif ((x == "-rx") or (x == "-xr") or
               (x == "-hx") or (x == "-xh"))
          ret[:act], wantargs = :helpx, nil
        elsif ((x == "-s") or (x == "--strict"))
          ret[:filtmode] = :strict
        elsif ((x == "-t") or (x == "--tags"))
          ret[:act] = :tags
        elsif ((x == "-x") or (x == "--examples"))
          ret[:act] = :examples
        elsif (x.match(/^-+[a-z]+/))
          ret[:act] = :err
        end

        args.delete_at(0)
        break if ret[:act] == :demo
      end

      ret[:act] = :read if ret[:act].nil?
      ret[:args] = args if wantargs

      # No meta-demos allowed.
      ret[:act] = :demodup if (demo) and (ret[:act] == :demo)
    end

    return ret
  end



  def main
    ret = nil

    if (self.act == :read)
      ret = self.cull_lines

    elsif (self.act == :commands)
      puts BM.show_commands

    elsif (self.act == :delete)
      ret = self.delete_line

    elsif (self.act == :demo)
      ret = self.run_demo

    elsif (self.act == :demodup)
      ret = self.out_msg(:demodup)

    elsif (self.act == :err)
      ret = self.out_msg(:argsbad, true)

    elsif (self.act == :examples)
      puts BM.show_examples

    elsif (self.act == :help)
      puts BM.help_msg

    elsif (self.act == :helpx)
      puts BM.help_msg + "\n" + BM.extra_notes

    elsif (self.act == :init)
      ret = self.init_file

    elsif (self.act == :new)
      ret = self.new_line

    elsif (self.act == :tags)
      self.print_tags

    else   # Strange fire.
      ret = self.out_msg(:actbad, self.act)
    end

    puts ret if ret.is_a? String
  end





  #
  # Methods related to the file.
  #

  def check_file!
    self.has_file, self.nil_file = self.has_file?, self.file_empty?
  end

  def has_file?
    if File.file?(self.file_path) then true else nil end
  end

  def file_empty?
    if File.zero?(self.file_path) then true else nil end
  end


  def make_file
    f = File.new(self.file_path, 'w+', 0600)
    self.check_file!  # Updates the @has_file and @nil_file bools.
    return self.has_file
  end

  def make_backup_file!
    self.bk_file = self.file_path + BM.backup_ext 
    IO.copy_stream(self.file_path, self.bk_file)
  end

  def delete_backup_file!
    File.delete(self.bk_file)
    self.bk_file = nil
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





  #
  # Methods related to the lines.
  #

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
        if self.val.nil?
          ret = self.out_msg(:valno)
        else
          ret = self.sysact.call
        end
      end
    end

    return ret
  end



  # Reads the file.
  # Filters lines from the file that match the @args.
  # Fills in the @lines array.
  def read_lines!(filts = self.args)
    ret = [ ]

    if self.has_file and !self.nil_file
      filts = (filts.empty?) ? [ ] : self.args_to_filts
      fh = File.open(self.file_path, 'r')
      while line = fh.gets(BM.line_sep)
        line = line.chomp(BM.line_sep).strip
        ret.push(line) if self.does_line_match?(line, filts)
      end
      fh.close
    end

    self.lines = ret
    self.sort_lines! if (!ret.empty?)
  end



  def sort_lines!
    hsh = { }
    self.lines.each do |line|
      p = self.line_to_parts(line)
      hsh[p[:val]] = line
    end

    ks, arr = hsh.keys.sort, [ ]
    ks.each { |k| arr.push(hsh[k]) }
    self.lines = arr
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



  def write_lines
    ret = nil

    if self.has_file
      fh, n, m = File.open(self.file_path, 'w'), 0, self.lines.length
      self.lines.each do |line|
        fh.puts line
        n += 1
        fh.puts BM.line_sep if (n < m)
      end
      fh.close
      self.check_file!
      ret = self.has_file
    end

    return ret
  end



  def remove_line_from_lines!
    self.lines.delete self.line
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





  #
  # Methods related to the line.
  #


  # When the action is to create a new line, main calls this.
  def new_line
    if self.args.empty?
      ret = self.out_msg(:argsno)

    else
      ret = (self.has_file) ? "\n" : self.init_file
      self.line_from_args!
      self.chop_val!

      if self.write_line
        ret <<
          "\n" + self.out_msg(:saveok) +
          "\n" + self.sysact.call
      else
        ret << "\n" + self.out_msg(:savefail)
      end

      ret = ret.strip
    end

    return ret
  end



  # When the action is to delete a line, main calls this.
  def delete_line
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
        self.remove_line_from_lines!
        self.make_backup_file!
        if self.write_lines
          self.delete_backup_file!
          ret = self.out_msg(:delok, self.clean(self.val))
        else
          ret = self.out_msg(:delfail, true)
        end
      end
    end

    return ret
  end



  def write_line
    ret = nil

    if self.has_file
      fh = File.open(self.file_path, 'a+')
      if self.nil_file
        fh.puts self.line
      else
        fh.puts BM.line_sep + "\n" + self.line
      end
      fh.close
      self.check_file!
      ret = self.has_file
    end

    return ret
  end



  def get_wanted_line!
    if self.lines.empty?
      self.line = nil
    else
      # If only one line matches, skip the browsing step.
      if self.lines.count == 1   # (self.act == :filt)
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



  def does_line_match?(line = self.line, filts = self.args)
    ret = nil

    if !line.empty?
      if filts.empty?
        ret = true

      else
        if self.inclusive?
          goodlim, loose = 1, true
        else
          goodlim, loose = filts.length, nil
        end
        p, good = self.line_to_parts(line), 0

        filts.each do |filt|
          if p[:tags].empty?
            good += 1 if p[:val].downcase.include? filt
          else
            p[:tags].each do |tag|
              if loose
                good += 1 if tag.include? filt
              else
                good += 1 if tag.downcase == filt
              end
            end
          end
        end
        ret = true if good >= goodlim
      end
    end

    return ret
  end



  def line_from_args!(arr = self.args)
    ret = nil

    if arr.is_a? Array
      val = arr.pop
      if arr.empty?
        ret = val
      else
        tags = arr.sort
        ret = tags.join(BM.tag_sep) + BM.tag_sep + val
      end
      ret = self.escape(ret)
    end

    self.line = ret
  end



  def line_to_parts(str = self.line)
    ret = { :val => '', :tags => [ ] }

    arr = str.split(BM.tag_sep)
    ret[:val] = arr.pop
    ret[:tags] = arr.sort.collect { |t| t.strip } if !arr.empty?

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





  #
  # Methods related to the value.
  #

  # This chops the value field from the given line and saves it.
  def chop_val!
    ret, str = nil, self.line

    if str.is_a? String
      ret = (str.include? BM.tag_sep) ? str.split(BM.tag_sep).last : str
      ret = ret.strip
    end

    self.val = ret
  end



  def copy_val
    chk = self.copy_val?
    if chk.nil?
      ret = self.out_msg(:pipefail)
    else
      ret = self.out_msg(:pipeok, self.clean(self.val))
    end
    return ret
  end


  def copy_val?(str = self.val)
    return nil if !str.is_a? String

    # Echo's -n flag doesn't work as expected here. It gets copied.
    #chk = system("echo -n \"#{str}\" | pbcopy")
    chk = system("printf \"#{str.gsub(/%/, '%%')}\" | pbcopy")
    ret = (chk) ? true : nil
    return ret
  end



  def open_val
    chk = self.open_val?
    if chk.nil?
      ret = self.out_msg(:openfail)
    else
      ret = self.out_msg(:openok, self.clean(self.val))
    end
    return ret
  end


  def open_val?(str = self.val)
    return nil if !str.is_a? String

    chk = system("open \"#{self.val}\"")
    ret = (chk) ? true : nil
    return ret
  end



  def get_system_action
    if self.pipe_to == :open
      ret = Proc.new { self.open_val }
    else
      ret = Proc.new { self.copy_val }
    end

    return ret
  end





  #
  # Methods related to the arguments.
  #

  def inclusive?
    if self.filter_mode == :loose then true else nil end
  end


  def args_to_filts(args = self.args)
    # They are escaped because they are stored escaped.
    args.collect! { |f| self.escape(f).downcase }
    return args.uniq
  end





  #
  # This just prints the tags and their counts.
  #

  # When the action is to view tags, main calls this.
  def print_tags
    tags = self.cull_tags
    tags.each { |tag,count| puts "#{tag} (#{count})" }
  end



  def cull_tags
    ret = { }

    if ((self.has_file) and (!self.nil_file))
      fh = File.open(self.file_path, 'r')
      while line = fh.gets(BM.line_sep)
        p = self.line_to_parts(line)
        if !p[:tags].empty?
          p[:tags].each do |tag|
            ret[tag] = 0 if !ret.has_key?(tag)
            ret[tag] += 1
          end
        end
      end

      keys, tmp = ret.keys.sort, { }
      keys.each { |k| tmp[k] = ret[k] }
      ret, tmp = tmp, nil
    end

    return ret
  end





  #
  # This returns a message according to the given key.
  #

  def out_msg(x = :bork, v = nil)
    x = :bork if !x.is_a? Symbol

    if (x == :actbad)
      ret = (v.nil?) ? "Invalid action. Strange fire." : "Invalid action: '#{v}'. Strange fire."

    elsif (x == :argsbad)
      ret = "Bad arguments, friendo."
      ret << "\n\n" + BM.show_commands if v

    elsif (x == :argsno)
      ret = "No arguments. Try something like \"bm good stuff\"."

    elsif (x == :delfail)
      ret = "Something went wrong with deleting the line."
      ret << " A backup file was created at \"#{self.bk_file}\"." if v

    elsif (x == :delnah)
      ret = "Nevermind? Okay."

    elsif (x == :delok)
      ret = (v.nil?) ? "Consider it gone." : "Deleted \"#{v}\"."

    elsif (x == :demodup)
      ret = "No meta-demos, buster."

    elsif (x == :fileempty)
      ret = "#{self.file_name} is empty. You can add lines with \"bm -n what ever\"."

    elsif (x == :fileexists)
      ret = "#{self.file_name} already exists."

    elsif (x == :filefail)
      ret = "Failed to create #{self.file_name} :("

    elsif (x == :fileno)
      ret = "Can't read #{self.file_name} because it doesn't exist. Run \"bm -i\"?"

    elsif (x == :init)
      ret = "Created #{self.file_name}."

    elsif (x == :linesno)
      ret = "#{self.file_name} has no valid lines."

    elsif (x == :matchno)
      ret = "No lines match."

    elsif (x == :openfail)
      ret = "Failed to open :("

    elsif (x == :openok)
      ret = (v.nil?) ? "Opened it." : "Opened \"#{v}\"."

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





  #
  # Runs the demo.
  #

  def run_demo
    BMdemo.new(self.args).main
  end

end





#
# Methods for the demo.
# To run it, prepend "--demo" to any normal string of arguments.
# Such as "bm --demo -a" or "bm --demo -o book".
#

class BMdemo < BM

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



  def initialize(args)
    super(args, true)
  end


  def main
    self.start!

    if self.has_file
      puts "#{self.out_msg(:start, BM.has_file?)}\n\n"

      super
      if self.stop
        ret = self.out_msg(:done, BM.has_file?)
      else
        ret = self.out_msg(:delfail)
      end
    else
      ret = self.out_msg(:startfail)
    end

    puts "\n#{ret}"
  end


  def start!
    self.make_file
    if self.has_file
      self.write_lines
    end
  end


  def write_lines
    self.lines = [ ]
    BMdemo.filler_lines.each do |arr|
      self.lines.push(self.line_from_args!(arr))
    end
    return super
  end


  def stop
    if self.has_file
      File.delete(self.file_path)
      self.check_file!
      ret = (self.has_file) ? nil : true
    else
      ret = true
    end

    return ret
  end



  # Messages unique to the demo.
  def out_msg(x = :bork, v = nil)
    x = :bork if !x.is_a? Symbol

    if (x == :delfail)
      ret = "Failed to delete the demo file, #{self.file_name}. Lame."

    elsif (x == :done)
      if v.nil?
        ret = "And that's how it works! To get started, type \"bm -i\", or add a line with something like \"bm -n what ever\"."
      else
        ret = "Removed the demo file, #{self.file_name}."
      end

    elsif (x == :start)
      ret = "This is a demo of #{"bm".bold}. It is running from a demo file, #{self.file_name}."
      ret << " Your #{BM.file_name} is safe." if v

    elsif (x == :startfail)
      ret = "Unable to run the demo :("

    else
      ret = super(x, v)
    end

    return ret
  end

end





class String
  def syscmd;   self.bold.green end
  def bmcmd;    self.bold end
  def header;   self.upcase.bold end


  # Clipped these from:
  # http://stackoverflow.com/questions/1489183/colorized-ruby-output
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
