Pup Tent
----

Pup Tent is an app for [macOS High Sierra](https://www.apple.com/macos/high-sierra) with a drag-and-drop interface for making small, static web sites. It's ideal for publishing [Github Pages.](https://pages.github.com) Build from source by archiving the `PupTent` target or grab the **[pre-built, developer-signed binary.](https://github.com/toddheasley/puptent/raw/master/PupTent.zip)**

![](https://github.com/toddheasley/puptent/raw/master/PupTent.png)

----

Behind the scenes, Pup Tent uses `PupKit` framework, which includes a command-line interface. To use Pup Tent from the command line, archive the `PupKitCLI` target and move the archived `pup` executable into an empty directory. In the Terminal, `cd` into the directory and run:

`./pup pitch`

![](https://github.com/toddheasley/puptent/raw/master/PupKitCLI.png)

An `ls` will reveal that a site skeleton has been created with the following:

* `index.json` - Configure the site and manage pages
* `default.css` - Style the site with CSS
* `apple-touch-icon.png` - Add a custom bookmark icon
* `media` - Add media associated with pages

To generate the actual HTML pages, run:

`./pup build`

To clean up any files and pages no longer referenced in the `index.json` site manifest, run:

`./pup clean`
