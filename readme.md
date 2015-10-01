# README

Simple Text Archiving and Retrieving

`star` is a simple tool for saving and retrieving bits of text. You could use it to save bookmarks, hard-to-remember commands, complex emoticons, stuff like that. It's similar to the most excellent [boom][] by Zach Holman but suits me better.


## Installation

Installation is very easy:

1. Clone the repo.
2. `cd` into the `star` directory.
3. Symlink the `star.rb` executable somewhere in your `$PATH`, such as `/usr/local/bin`: `sudo ln -s star.rb /usr/local/bin/star`.

Its only dependencies come built in with OS X.


## Usage

So say you want to save Wikipedia's page on Tardigrades. You would enter:

	$ star -n https://en.wikipedia.org/wiki/Tardigrade

Then, when you want to read about those creepy cool animals again, you can type:

	$ star Tardigrade

And, assuming you haven't saved anything else that includes the word "Tardigrade", `star` will copy that URL to your clipboard. Or you can type:

	$ star -o Tardigrade

and the URL will be opened in your browser.

To help with retrieving things later, you can tag can your entries by entering words before the value you want to copy or open. So say you want to tag Wikipedia's page on the Flammarion Engraving with "wiki" and "art":

	$ star -n wiki art http://en.wikipedia.org/wiki/Flammarion_engraving

To see all your entries tagged "wiki":

	$ star wiki

To see all your entries tagged both "wiki" and "art":

	$ star wiki art

To see all your entries tagged either "wiki" or "art":

	$ star -l wiki art

If multiple entries match the given tags, you'll be shown a numbered list of them and prompted to enter the number of the one you want. The text on the numbered line will be `pbcopy`'d or `open`ed. Tags are listed beneath the numbered line. The lists look something like this:

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

You can edit, add, and remove entries in your editor of choice with:

    $ star -e

You can also delete entries with:

	$ star -d

To see a list of commands:

	$ star -c

And to run a little demo:

	$ star --demo


## Storage & configuration

`star` saves your text in a plain text file, by default at `~/.config/star/store` but you can change that.

Configuration options are read from a YAML file, `~/.config/star/config.yaml`, which lists key-value pairs. Here's a sample:

    file_name: ~/.config/star/store
    filter_mode: strict
    pipe_to: copy

If you prefer the loose filter mode, change the `filter_mode` to `loose`. And if you'd prefer the values to be opened by default, then change `copy` to `open`.




[boom]: http://zachholman.com/boom/
