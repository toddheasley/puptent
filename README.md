![](https://raw.githubusercontent.com/toddheasley/puptent/master/PupTent/Images.xcassets/AppIcon.appiconset/AppIcon-32@2x.png)

Built on the belief that there's still a place for personal, snack-size web pages, Pup Tent is a Mac app with a simple drag-and-drop interface for making small, static HTML sites. It's ideal for publishing to [Github Pages](https://pages.github.com) and provides an ultra-lightweight alternative to [Cactus](https://github.com/koenbok/Cactus) and [Jekyll](http://jekyllrb.com).

---

Pup Tent is powered by `PupKit` framework, which includes a command line inteface. To use Pup Tent from the command line, archive the `puptent` target and move the archived executable into an empty directory. In the Mac Terminal, `cd` into the directory and run:

`./puptent pitch`

An `ls` will reveal that a site skeleton has been created with the following:

* `index.json` - Configure the site and manage pages
* `default.css` - Style the site with CSS
* `apple-touch-icon.png` - Add a custom bookmark icon 
* `media` - Add media associated with pages

To generate the actual HTML pages, run:

`./puptent build`

To clean up any files and pages no longer referenced in the `index.json` site manifest, run:

`./puptent clean`