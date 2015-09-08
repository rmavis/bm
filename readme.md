# README

Simple Text Archiving and Retrieving

`star` is a simple tool for saving and retrieving bits of text. You could use it to save bookmarks, hard-to-remember commands, complex emoticons, stuff like that. It's similar to the most excellent [boom][] by Zach Holman but suits me better.

Installation is very easy. There's a demo, so you can try it before you take the plunge and symlink to your `/usr/local/bin`. And its only external dependencies come built in with OS X.

So say you want to save Wikipedia's page on Tardigrades. You would enter:

	$ star -n https://en.wikipedia.org/wiki/Tardigrade

Then, when you want to read about those creepy cool animals again, you can type:

	$ star Tardigrade

And, assuming you haven't saved anything else that includes the word "Tardigrade", `star` will copy that URL to your clipboard. Or you can type:

	$ star -o Tardigrade

and the URL will be opened in your default browser.

To help with retrieving things later, you can tag can your entries by entering words before the value you want to copy or open. So say you want to tag Wikipedia's page on the Flammarion Engraving with "wiki" and "art":

	$ star -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

To see all your entries tagged "wiki":

	$ star wiki

To see all your entries tagged both "wiki" and "art":

	$ star wiki art

To see all your entries tagged either "wiki" or "art":

	$ star -l wiki art

If multiple entries match the given tags, then you'll be shown a numbered list of them and prompted for the one you want. The text on the numbered line will be `pbcopy`'d or `open`ed. Tags are listed beneath the numbered line. The lists look something like this:

    1) http://printingcode.runemadsen.com/lecture-intro/
       Tags: art, computers, design, generative, history
    2) https://en.wikipedia.org/wiki/El_Lissitzky
       Tags: El Lissitzky, art, design
    3) http://yaleunion.org/
       Tags: art, portland, web design
    4) http://en.wikipedia.org/wiki/Netherlandish_Proverbs
       Tags: Netherlandish Proverbs, Pieter Bruegel the Elder, art, wiki
    5) http://settlement.arc.nasa.gov/70sArtHiRes/70sArt/art.html
       Tags: NASA colonies, art, space
    0) None.
    ?: 

But if there's only one match, you'll skip the browsing step.

`star` saves your text in a plain text file, by default at `~/.config/star/store` but you can change that.

You can edit, add, and remove values in your editor of choice with:

    $ star -e

You can also delete values with:

	$ star -d

To see a list of commands:

	$ star -c

And to run a little demo:

	$ star --demo



[boom]: http://zachholman.com/boom/
