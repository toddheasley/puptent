<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    class Page {
        
        // 
        // Page Model and Controller
        // ----------
        // Pup Tent builds a simple web site from static HTML web pages. Each page object
        // represents a single HTML page, with the page's file name acting as its unique
        // identifier. File name is set when the page instance is created and becomes a
        // read-only property during the lifespan of the page instance.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected $fileName; // Base name of HTML file
        protected $title;  // Title text
        protected $description; // Meta description text
        protected $sections; // Indexed array of page section objects in order
        
        // 
        // ----------
        // Magic methods
        // 
        
        function __construct($fileName, $json = NULL) {
            if (strlen($fileName) < 1 || $fileName == "index") {
                
                // File name is not valid; abort page instantiation.*
                return;
            }
            
            // Set file name.
            $this->fileName = $fileName;
            
            // Initialize class properties to default non-null values;
            $this->title = "";
            $this->description = "";
            $this->sections = array();
            
            // Construct instance from JSON argument or existing JSON file.
            $this->fromJSON($json);
        }
        
        function __destruct() {
            if (! JSON::exists($this->fileName)) {
                
                // Page has not been saved to file; delete any associated files and media.**
                JSON::delete($this->fileName);
            }
        }
        
        function __set($name, $value) {
            switch ($name) {
                case "title":
                    $this->title = Format::plainText($value);
                    break;
                case "description":
                    $this->description = Format::plainText($value);
                    break;
                case "sections":
                    if (! is_array($value)) {
                        return;
                    }
                    foreach ($this->sections as $section) {
                        if (in_array($section, $value)) {
                            
                            // Existing section is not present in new array; remove associated media items.
                            $section->media = array();
                        }
                    }
                    $this->sections = $value;
            }
        }
        
        function __get($name) {
            if (! isset($this->$name)) {
                return;
            }
            return $this->$name;
        }
        
        // 
        // ----------
        // Public methods
        // 
        
        public function save() {
            
            // Save page as JSON.
            $this->toJSON();
            
            // Save page as HTML.
            PageHTML::save($this);
            
            // Add page to site index.
            $index = new Index;
            $indexItem = new IndexItem;
            $indexItem->fileName = $this->fileName;
            $indexItem->title = $this->title;
            $index->addItem($indexItem);
            $index->save();
        }
        
        public static function delete($fileName) {
            if (! JSON::exists($fileName)) {
                return false;
            }
            $page = new Page($fileName);
            
            // Remove page from site index.
            $index = new Index;
            $index->removeItem($page->fileName);
            $index->save();
            
            // Delete static JSON file.
            JSON::delete($page->fileName);
            
            // Delete static HTML file.
            PageHTML::delete($page->fileName);
            
            // Delete all associated media.
            foreach ($page->sections as $section) {
                foreach ($section->media as $media) {
                     Media::removeItem($media);
                }
            }
            return true;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected function toJSON() {
            
            // Transform page object into a generic object and save to static JSON file.
            $object->fileName = $this->fileName;
            $object->title = $this->title;
            $object->description = $this->description;
            $object->sections = array();
            foreach ($this->sections as $section) {
                $object->sections[] = $section->toObject();
            }
            JSON::save($this->fileName, $object);
        }
        
        protected function fromJSON($json = NULL) {
            if (! is_null($json)) {
                $object = JSON::decode($json);
            } else if (JSON::exists($this->fileName)) {
                $object = JSON::read($this->fileName);
            }
            if (! isset($object->title, $object->description, $object->sections)) {
                return;
            }
            $this->title = $object->title;
            $this->description = $object->description;
            foreach ($object->sections as $section) {
                $this->sections[] = new PageSection($section);
            }
        }
        
        // 
        // Notes
        // ----------
        // * Pup Tent reserves the file name "index" as the unique identifier for the site
        // index page.
        // 
        // ** Because Pup Tent uses relative file paths, to prevent media associated with
        // unsaved pages from being orphaned, destruct should be called manually in the
        // page context. (See: http://php.net/manual/en/language.oop5.decon.php)
        // 
    }
    
    class PageSection {
        
        // 
        // Page Section Model and Controller
        // ----------
        // The page section is the basic building block of the page -- a unit of content
        // that comes in 4 different flavors (or page section types):
        //     * Basic text block
        //     * Image file(s) with optional text caption
        //     * Audio file with optional text caption
        //     * Video file with optional text caption
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected $type; // Page section type
        protected $text; // Section text
        protected $media; // Indexed array of media file paths
        
        // 
        // ----------
        // Magic methods
        // 
        
        function __construct($object = NULL) {
            
            // Initialize class properties to default non-null values;
            $this->type = PageSectionType::$basic;
            $this->text = "";
            $this->media = array();
            
            if (! is_null($object)) {
                
                // Reconstruct instance from generic object.
                $this->fromObject($object);
            }
        }
        
        function __set($name, $value) {
            switch ($name) {
                case "type":
                    if (is_int($value)) {
                        $this->type = $value;
                    }
                    break;
                case "text":
                    $this->text = Format::plainText($value);
                    if ($this->type == PageSectionType::$basic) {
                        $this->text = Format::inlineHTML($value);
                    }
                    break;
                case "media":
                    if (! is_array($value)) {
                        return;
                    }
                    foreach ($this->media as $media) {
                        if (in_array($media, $value)) {
                            
                            // Existing media item is not present in new array; remove media item.
                            Media::removeItem($media);
                        }
                    }   
                    $this->media = $value;
            }
        }
        
        function __get($name) {
            if (! isset($this->$name)) {
                return;
            }
            return $this->$name;
        }
        
        // 
        // ----------
        // Public methods
        // 
        
        public function toObject() {
            
            // Transform page section into a generic object.
            $object->type = $this->type;
            $object->text = $this->text;
            $object->media = $this->media;
            return $object;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected function fromObject($object) {
            
            // Reconstruct instance from object argument.
            $this->type = $object->type;
            $this->text = $object->text;
            $this->media = $object->media;
        }
    }
    
    class PageSectionType {
        
        // 
        // Page Section Type Definition
        // ----------
        // Reference names for page section types
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        public static $basic = 0; // Basic text block
        public static $image = 1; // Image(s)
        public static $audio = 2; // Audio
        public static $video = 3; // Video
    }
    
    class PageHTML {
        
        // 
        // Page HTML
        // ----------
        // When a page is saved, a static HTML file is generated from the page object
        // using an HTML template file. Likewise, when a page is deleted, its static HTML
        // file is also deleted.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected static $templatePath = "HTML/Page.html"; // Path to HTML page template file
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function save($page) {
            
            // Encode HTML and save to static HTML file.
            file_put_contents(self::path($page->fileName), self::encode($page));
        }
        
        public static function delete($fileName) {
            if (self::exists($fileName)) {
                unlink(self::path($fileName));
            }
        }
        
        public static function exists($fileName) {
            if (file_exists(self::path($fileName))) {
                return true;
            }
            return false;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected static function path($fileName) {
            
            // Return relative path to static HTML file.
            return "../" . $fileName . ".html";
        }
        
        protected static function encode($page) {
            
            // Set HTML meta generator string.
            $generator = TITLE . " " . VERSION;
            
            // Parse HTML template into components.*
            $components = explode("<!-- /// -->", file_get_contents(self::$templatePath));
            
            // Concatenate HTML string and swap in page content.
            $html = "";
            $html .= ltrim($components[0]);
            if (strlen($page->description) > 0) {
                $html .= ltrim($components[1]);
            }
            $html .= ltrim($components[2]);
            if (strlen($page->title) > 0) {
                $html .= ltrim($components[3]);
            }
            if (strlen($page->description) > 0) {
                $html .= ltrim($components[4]);
            }
            foreach ($page->sections as $section) {
                $htmlSection = "";
                switch ($section->type) {
                    case PageSectionType::$basic:
                        if (strlen($section->text) > 0) {
                            
                            // Add a basic text section to HTML string.
                            $htmlSection .= ltrim($components[5]);
                            $htmlSection = str_replace("<!-- Text -->", $section->text, $htmlSection);
                        }
                        break;
                    case PageSectionType::$image:
                        if (count($section->media) > 0) {
                            
                            // Add an image(s) section to HTML string.
                            $htmlSection .= ltrim($components[6]);
                            foreach ($section->media as $media) {
                                $htmlSection .= ltrim($components[7]);
                                $htmlSection = str_replace("<!-- Media path -->", Format::mediaURL($media), $htmlSection);
                            }
                            if (strlen($section->text) > 0) {
                                $htmlSection .= ltrim($components[10]);
                            }
                            $htmlSection = trim($htmlSection);
                            $htmlSection .= ltrim($components[11]);
                            $htmlSection = str_replace("<!-- Text -->", $section->text, $htmlSection);
                        }
                        break;
                    case PageSectionType::$audio:
                        if (! is_null($section->media[0])) {
                            
                            // Add an audio section to HTML string.
                            $htmlSection .= ltrim($components[6]);
                            $htmlSection .= ltrim($components[8]);
                            $htmlSection = str_replace("<!-- Media path -->", Format::mediaURL($media), $htmlSection);
                            if (strlen($section->text) > 0) {
                                $htmlSection .= ltrim($components[10]);
                            }
                            $htmlSection = trim($htmlSection);
                            $htmlSection .= ltrim($components[11]);
                            $htmlSection = str_replace("<!-- Text -->", $section->text, $htmlSection);
                        }
                        break;
                    case PageSectionType::$video:
                        if (! is_null($section->media[0])) {
                            
                            // Add a video section to HTML string.
                            $htmlSection .= ltrim($components[6]);
                            $htmlSection .= ltrim($components[9]);
                            $htmlSection = str_replace("<!-- Media path -->", Format::mediaURL($media), $htmlSection);
                            if (strlen($section->text) > 0) {
                                $htmlSection .= ltrim($components[10]);
                            }
                            $htmlSection = trim($htmlSection);
                            $htmlSection .= ltrim($components[11]);
                            $htmlSection = str_replace("<!-- Text -->", $section->text, $htmlSection);
                        }
                        break;
                }
                $html .= $htmlSection;
            }
            $html = str_replace("<!-- Generator -->", $generator, $html);
            $html = str_replace("<!-- Title -->", $page->title, $html);
            $html = str_replace("<!-- Description -->", $page->description, $html);
            return trim($html);
        }
        
        // 
        // Notes
        // ----------
        // * Because the HTML template is parsed primitively into a one-dimensional
        // indexed array of components, rather than a more robust template object or
        // schema, any additions to the HTML template could potentially alter the index
        // of all of the components.
        // 
    }

?>