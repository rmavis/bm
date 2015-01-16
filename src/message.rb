#
# Messages.
#



module Star
  class Message

    def self.p_indent;   2 end


    def self.help_msg
      ret = 
        "Readme".header.form_p +

        "#{"star".header}: Simple Text Archiver And Retriever".form_p(Star::Message.p_indent) +

        "#{"star".command} is a simple tool for saving and retrieving bits of text. You could use it to save bookmarks, hard-to-remember commands, complex emoticons, stuff like that.".form_p(Star::Message.p_indent) +

        "Say you want to save Wikipedia's page on Tardigrades. You would enter:".form_p(Star::Message.p_indent, nil) +
        "$ star -n https://en.wikipedia.org/wiki/Tardigrade".form_p(Star::Message.p_indent * 2) +

        "Then, when you want to read about those creepy cool animals again, you can type:".form_p(Star::Message.p_indent, nil) +
        "$ star tardigrade".form_p(Star::Message.p_indent * 2, nil) +
        "And, assuming you haven't saved anything else that includes the word \"Tardigrade\", #{"star".command} will copy the URL to your clipboard. Or you can type:".form_p(Star::Message.p_indent, nil) +
        "$ star -o tardigrade".form_p(Star::Message.p_indent * 2, nil) +
        "and the URL will be opened in your default browser.".form_p(Star::Message.p_indent) +

        "To help with retrieving things later, you can tag your saves by entering words before the value you'd want to copy or open. So say you want to save Wikipedia's page on the Flammarion Engraving and tag it \"wiki\" and \"art\":".form_p(Star::Message.p_indent, nil) +
        "$ star -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving".form_p(Star::Message.p_indent * 2) +

        "To see all your saves tagged \"wiki\":".form_p(Star::Message.p_indent, nil) +
        "$ star wiki".form_p(Star::Message.p_indent * 2) +

        "To see all your saves tagged both \"wiki\" and \"art\":".form_p(Star::Message.p_indent, nil) +
        "$ star wiki art".form_p(Star::Message.p_indent * 2) +

        "If there's only one match, the value will be copied to your clipboard or opened. If there are multiple matches, then you'll be shown a numbered list of them and prompted for the one you want.".form_p(Star::Message.p_indent) +

        "#{"star".command} saves your text in a plain text file. The default location is".form_p(Star::Message.p_indent, nil) +
        Star::Config.store_file_name.form_p(Star::Message.p_indent * 2, nil) +
        "but you can change that if you want to.".form_p(Star::Message.p_indent) +

        "To see a list of commands:".form_p(Star::Message.p_indent, nil) +
        "$ star --commands".form_p(Star::Message.p_indent * 2) +

        "And to run a little demo:".form_p(Star::Message.p_indent, nil) +
        "$ star --demo".form_p(Star::Message.p_indent * 2)

      return ret
    end



    def self.show_commands
      ret = <<END
#{"Flags".header}
  -a, --all        Show all saves.
  -c, --commands,
    -f, --flags    Show this message.
  -d, --delete     Delete a save.
  -i, --init       Create the #{Star::Config.store_file_name} file.
  -l, --loose      Match loosely, rather than strictly.
  -m, --demo       Run the demo.
  -n, --new        Add a new line.
  -o, --open       #{"open".command} the value rather than #{"pbcopy".command} it.
  -p, --copy       #{"pbcopy".command} the value rather than #{"open".command} it.
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
      ret =
        "Examples".header.form_p +

        "See a numbered list of all your saves:".form_p(Star::Message.p_indent, nil) +
        "$ star -a".form_p(Star::Message.p_indent * 2, nil) +
        "You'll be prompted to enter the number of the line you want. That line will be piped to #{"pbcopy".command}, thereby copying it to your clipboard.".form_p(Star::Message.p_indent) +

        "Save a new line to your #{Star::Config.store_file_name}:".form_p(Star::Message.p_indent, nil) +
        "$ star -n music \"Nils Frahm\" Screws http://screws.nilsfrahm.com/".form_p(Star::Message.p_indent * 2, nil) +
        "The URL is the value that will be piped to #{"pbcopy".command} or passed to #{"open".command}. The other parts of the line are the tags, which will be checked when you run other commands.".form_p(Star::Message.p_indent) +

        "See a numbered list of your saves tagged \"music\":".form_p(Star::Message.p_indent, nil) +
        "$ star music".form_p(Star::Message.p_indent * 2, nil) +
        "As with #{"star -a".command}, you'll be prompted to enter the number of the line you want piped to #{"pbcopy".command}. If only one value matches, you won't be prompted for a line. See the important note before.".form_p(Star::Message.p_indent) +

        "Identical to #{"star music".command} but the list will show your saves tagged both \"weird\" and \"music\".".form_p(Star::Message.p_indent, nil) +
        "$ star weird music".form_p(Star::Message.p_indent * 2) +

        "Identical to #{"star music".command} but the list will show your saves tagged either \"weird\" or \"music\".".form_p(Star::Message.p_indent, nil) +
        "$ star -l weird music".form_p(Star::Message.p_indent * 2) +

        "Identical to #{"star music".command} but the value on the line you enter will be passed to #{"open".command}. So URLs should open in your default browser, files and directories should #{"open".command} as expected, etc.".form_p(Star::Message.p_indent, nil) +
        "$ star -o music".form_p(Star::Message.p_indent * 2) +

        "Identical to #{"star music".command} but the matching line will be deleted from your #{Star::Config.store_file_name}.".form_p(Star::Message.p_indent, nil) +
        "$ star -d music".form_p(Star::Message.p_indent * 2)

      return ret + "\n" + Star::Message.imp_note
    end



    def self.imp_note
      ret =
        "Important".header.form_p +
        "If only one save matches the tags you specify, then you will not be shown a numbered list of matches. Instead, that step will be skipped and the value will be copied, opened, or deleted accordingly.".form_p(Star::Message.p_indent) +
        "So if only one save is tagged \"music\", then #{"star -o music".command} will pass the matching value to #{"open".command}, and #{"star -d music".command} will delete the save from your #{Star::Config.store_file_name}.".form_p(Star::Message.p_indent)

      return ret
    end



    def self.extra_notes
      ret =
        "Extra".header.form_p +
        "If you feel list customizing #{"star".command}, you can edit the methods in #{__dir__}/config.rb.".form_p(Star::Message.p_indent, nil)
      ret << <<END
    1. The file name, #{Star::Config.store_file_name}, is specified in Config::file_name
       If you change this, make sure you have write privileges.
    2. The default filter mode is specified in Config::filter_mode
       The value should be a symbol, either :strict or :loose
    3. The default system action is specified in Config::pipe_to
       The value should be a symbol, either :copy or :open

END

      ret <<
        "The #{"star".command} file format uses the non-printing ASCII group, record, and unit separator characters. The group separator separates each \"line\". Each line is divided into three parts by record separators. The first part is the value that will be copied or opened. The second part holds the tags. The third part holds metadata. The individual tags and pieces of metadata are separated by unit separators.".form_p(Star::Message.p_indent) +
        
        "So each line looks something like this:".form_p(Star::Message.p_indent, nil) +
        "    http://en.wikipedia.org/wiki/Flammarion_engraving#{"^^".cyan}art#{"^_".cyan}wiki#{"^^".cyan}1417427624#{"^_".cyan}1417742246#{"^_".cyan}4#{"^]".cyan}\n\n" +

        "The metadata consists of two timestamps, indicating the times you created and last selected the associated value, and a running tally of the number of times you've selected that value.".form_p(Star::Message.p_indent) +

        "So if you want to edit the file in your editor of choice, do so with care. And beware that your editor might not display those non-printing characters or might display them weirdly. In #{"emacs".command}, you can enter the group separator with:".form_p(Star::Message.p_indent , nil) +
        "C-q 035 <RET>".form_p(Star::Message.p_indent * 2, nil) +
        "And the record separator with:".form_p(Star::Message.p_indent , nil) +
        "C-q 036 <RET>".form_p(Star::Message.p_indent * 2, nil) +
        "And the unit separator with:".form_p(Star::Message.p_indent , nil) +
        "C-q 037 <RET>".form_p(Star::Message.p_indent * 2)

      return ret
    end




    #
    # This returns a message according to the given key.
    # The calls to self will return values inherited from Star::Hub.
    #

    def self.out( x = :bork, v = nil )
      x = :bork if !x.is_a? Symbol

      if x == :actbad
        ret = (v.nil?) ? "Invalid action. Strange fire." : "Invalid action: '#{v}'. Strange fire."

      elsif x == :argsbad
        ret = "Bad arguments, friendo."
        ret << "\n\n" + Star::Message.show_commands if v

      elsif x == :argsno
        ret = "No arguments. Try something like \"star good stuff\"."

      elsif x == :delfail
        ret = "Something went wrong with deleting the line."
        ret << " A backup file was created at \"#{Star::Store.backup_file_name}\"." if v

      elsif x == :delnah
        ret = "Nevermind? Okay."

      elsif x == :delok
        ret = (v.nil?) ? "Consider it gone." : "Deleted \"#{v}\"."

      elsif x == :demodup
        ret = "No meta-demos, buster."

      elsif x == :fileempty
        fn = (v) ? v : 'The store file'
        ret = "#{fn} is empty. You can add lines with \"star -n what ever\"."

      elsif x == :fileexists
        fn = (v) ? v : 'The store file'
        ret = "#{fn} already exists."

      elsif x == :filefail
        fn = (v) ? v : 'the store file'
        ret = "Failed to create #{fn} :("

      elsif x == :fileno
        fn = (v) ? v : 'store file'
        ret = "Can't read #{fn} because it doesn't exist. Run \"star -i\"?"

      elsif x == :init
        ret = (v) ? "Created #{v}." : "Created store file."

      elsif x == :linesno
        fn = (v) ? v : 'The store file'
        ret = "#{fn} has no valid lines."

      elsif x == :matchno
        ret = "No lines match."

      elsif x == :openfail
        ret = "Failed to open :("

      elsif x == :openok
        ret = (v.nil?) ? "Opened it." : "Opened \"#{v}\"."

      elsif x == :pipefail
        ret = "Failed to copy value to clipboard. WTF?"

      elsif x == :pipeok
        ret = (v.nil?) ? "Good good." : "Copied \"#{v}\"."

      elsif x == :savefail
        ret = "Failed to save new line :("

      elsif x == :saveok
        ret = "Saved new line."

      elsif x == :valnah
        verb = (v == :copy) ? 'copied' : (v == :open) ? 'opened' : 'deleted'
        ret = "Nothing wanted, nothing #{verb}."

      elsif x == :valno
        ret = "Unable to find the value on \"#{v}\"."

      else
        ret = "Error: something unknown is doing we don't know what."
      end

      return ret
    end


  end
end
