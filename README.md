__Pup Tent__

Pup Tent is a Mac app that generates bite-size, static HTML sites. It's ideal for publishing to [Github Pages](https://pages.github.com) or [Amazon S3](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html) and provides an ultra-lightweight alternative to static site generators like [Cactus](https://github.com/koenbok/Cactus) and [Jekyll](http://jekyllrb.com).

An example of Pup Tent in action can be found at [toddheasley.github.io](http://toddheasley.github.io).

---

Pup Tent is powered by `PupKit` framework, which includes a command line inteface. To use Pup Tent from the command line, archive the `puptent` target and move the archived executable into an empty directory. In the Mac Terminal, `cd` into the directory and run:

`./puptent pitch`

An `ls` will reveal that a site skeleton has been created with the following:

* `index.json` - Configure the site and manage pages
* `default.css` - Style the site with CSS
* `apple-touch-icon.png` - Add a custom bookmark icon 
* `media` - Suggested (optional) directory for storing media associated with pages

To generate the actual HTML pages, run:

`./puptent build`

To clean up any files and pages no longer referenced in the `index.json` site manifest, run:

`./puptent clean`