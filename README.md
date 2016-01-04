Pup Tent
----

Pup Tent is a Mac app with a drag-and-drop interface for making small, static web sites. It's ideal for publishing to [Github Pages](https://pages.github.com). Build from source by archiving the `PupTent` target or grab the **[pre-built, developer-signed app](https://github.com/toddheasley/puptent/raw/master/PupTent.zip)**.

----

Behind the scenes, Pup Tent uses `PupKit` framework, which includes a command-line interface. To use Pup Tent from the command line, archive the `PupKitCLI` target and move the archived `pup` executable into an empty directory. In the Mac Terminal, `cd` into the directory and run:

`./pup pitch`

An `ls` will reveal that a site skeleton has been created with the following:

* `index.json` - Configure the site and manage pages
* `default.css` - Style the site with CSS
* `apple-touch-icon.png` - Add a custom bookmark icon
* `media` - Add media associated with pages

To generate the actual HTML pages, run:

`./pup build`

To clean up any files and pages no longer referenced in the `index.json` site manifest, run:

`./pup clean`
