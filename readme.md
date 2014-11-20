# README

`star` is a simple tool for saving and retrieving bits of text. You could use it to save bookmarks, hard-to-remember commands, complex emoticons, stuff like that. It's similar to the most excellent [boom][] by [Zach Holman][zh] but suits me better.

Its name stands for Simple Text Archiving and Retrieving. Its only external dependencies come built in with OS X.

So say you want to save Wikipedia's page on Tardigrades. You would enter:

	$ star -n https://en.wikipedia.org/wiki/Tardigrade

Then, when you want to read about those creepy cool animals again, you can type:

	$ star Tardigrade

And, assuming you haven't saved anything else that includes the word "Tardigrade", `star` will copy the URL to your clipboard. Or you can type:

	$ star -o Tardigrade

and the URL will be opened in your default browser.

To help with retrieving things later, you can tag can your saves by entering words before the value you want to copy or open. So say you want to tag Wikipedia's page on the Flammarion Engraving with "wiki" and "art":

	$ star -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

To see all your saves tagged "wiki":

	$ star wiki

To see all your saves tagged both "wiki" and "art":

	$ star wiki art

To see all your saves tagged either "wiki" or "art":

	$ star -l wiki art

If there are more than one saves that match the tags, then you'll be shown a numbered list of them and prompted for the one you want. The text on the numbered line will be copied to your clipboard. Tags will be listed beneath the numbered line. And if there's only one match, you'll skip the browsing step. You can see some examples [here][rfmstar].

`star` saves your text in a plain text file at ~/.star, so you can add, edit, and remove values in your editor of choice. You can also delete values with:

	$ star -d

To see a list of commands:

	$ star -c

And to run a little demo:

	$ star --demo



## And more

If you feel list customizing `star`, there are three class methods toward the top of the file that you can change:

1. The file name, ~/.star, is specified in `STAR::file_name`. If you change this, make sure you have write privileges.
2. The default filter mode is specified in `STAR::default_filter_mode`. The value should be a symbol, either `:strict` or `:loose`.
3. The default system action is specified in `STAR::default_pipe_to`. The value should be a symbol, either `:copy` or `:open`.

`star` uses the non-printing ASCII record and unit separator characters when saving your data. The record separator separates each "line". Each line holds the value that will be copied or opened along with any tags. If there are tags, they will be separated from the value and from each other by the unit separator. The value is the last slot in that line. Something like this:

	wiki^_art^_http://en.wikipedia.org/wiki/Flammarion_engraving
	^^
	music^_Nils Frahm^_Screws^_http://screws.nilsfrahm.com/
	^^
	https://en.wikipedia.org/wiki/Tardigrade

So if you want to edit the file in your editor of choice, beware that your editor might not display those characters, or might display them weirdly. In emacs, you can enter the record separator with:

	C-q 036 <RET>

And the unit separator with:

	C-q 037 <RET>




[zh]: http://zachholman.com/
[boom]: http://zachholman.com/boom/
[rfmstar]: http://richardmavis.info/star
