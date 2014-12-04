#
# Miscellaneous additions.
#



class String
  def syscmd;   self.bold.green end
  def starcmd;  self.bold end
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



  def puts_p( line_lim = 70, indent = 0 )
    use = self
    lim = (line_lim - 1)

    while !use.nil? and use.length > 0
      if use.length > lim
        chk = use.slice(0..lim)
        len = chk.rindex(' ') || lim
      else
        chk, len = use, use.length
      end

      indent.times { print ' ' }
      print chk.slice(0..len).strip + "\n"

      use = use.slice((len + 1)..use.length)
    end
  end

end




# "A Unix shell is a command-line interpreter or shell that provides a traditional user interface for the Unix operating system and for Unix-like systems. Users direct the operation of the computer by entering commands as text for a command line interpreter to execute, or by creating text scripts of one or more such commands. Users typically interact with a Unix shell using a terminal emulator, however, direct operation via serial hardware connections, or networking session, are common for server systems.".puts_p(3, 10)
