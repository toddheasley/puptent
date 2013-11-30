<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class Index {
        
        // 
        // Index Model and Controller
        // ----------
        // The Pup Tent index object contains the list of pages, as well as any site-wide
        // meta information.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected static $fileName = "index"; // Base name of index file
        protected $title; // Site title text
        protected $description; // Site meta description text
        protected $items; // Indexed array of index item objects in order
        protected $mailAddress; // Contact email address
        protected $twitterName; // Site Twitter account
        
        // 
        // ----------
        // Magic methods
        // 
        
        function __construct($json = NULL) {
            
            // Initialize class properties to default non-null values
            $this->title = "";
            $this->description = "";
            $this->items = array();
            $this->mailAddress = "";
            $this->twitterName = "";
            
            // Construct instance from JSON argument or existing JSON file
            $this->fromJSON($json);
        }
        
        function __set($name, $value) {
            switch ($name) {
                case "title":
                    $this->title = Format::plainText($value);
                    break;
                case "description":
                    $this->description = Format::plainText($value);
                    break;
                case "mailAddress":
                    $this->mailAddress = Format::mailAddress($value);
                    break;
                case "twitterName":
                    $this->twitterName = Format::twitterName($value);
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
            
            // Save index as JSON
            $this->toJSON();
            
            // Save index as HTML
            IndexHTML::save($this);
        }
        
        public function addItem($item) {
            $newItem = true;
            for ($i = 0; $i < count($this->items); $i++) {
                if ($this->items[$i]->fileName != $item->fileName) {
                    continue;
                }
                $this->items[$i] = $item;
                $newItem = false;
                break;
            }
            if ($newItem) {
                $this->items[] = $item;
            }
        }
        
        public function removeItem($fileName) {
            for ($i = 0; $i < count($this->items); $i++) {
                if ($this->items[$i]->fileName != $fileName) {
                    continue;
                }
                array_splice($this->items, $i, 1);
                break;
            }
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected function toJSON() {
            
            // Transform index object into a generic object and save to static JSON file
            $object->title = $this->title;
            $object->description = $this->description;
            $object->items = array();
            foreach ($this->items as $item) {
                $object->items[] = $item->toObject();
            }
            $object->mailAddress = $this->mailAddress;
            $object->twitterName = $this->twitterName;
            JSON::save(self::$fileName, $object);
        }
        
        protected function fromJSON($json = NULL) {
            if (! is_null($json)) {
                $object = JSON::decode($json);
            } else if (JSON::exists(self::$fileName)) {
                $object = JSON::read(self::$fileName);
            }
            if (! isset($object->title, $object->description, $object->items, $object->mailAddress, $object->twitterName)) {
                return;
            }
            $this->title = $object->title;
            $this->description = $object->description;
            foreach ($object->items as $item) {
                $this->items[] = new IndexItem($item);
            }
            $this->mailAddress = $object->mailAddress;
            $this->twitterName = $object->twitterName;
        }
    }
    
    class IndexItem {
        
        // 
        // Index Item Model and Controller
        // ----------
        // The index includes an array of all of the Pup Tent-managed pages that make up
        // the web site. Each page in the list is represented by an index item. Only public
        // index items appear in the index HTML file.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected $fileName; // Base name of page HTML file
        protected $title; // Page title text
        protected $public; // Boolean flag indicating visibility in index HTML
        
        // 
        // ----------
        // Magic methods
        // 
        
        function __construct($object = NULL) {
            
            // Initialize class properties to default non-null values
            $this->title = "";
            $this->fileName = "";
            $this->public = false;
            
            if (! is_null($object)) {
                
                // Reconstruct instance from generic object
                $this->fromObject($object);
            }
        }
        
        function __set($name, $value) {
            switch ($name) {
                case "fileName":
                    $this->fileName = $value;
                    break;
                case "title":
                    $this->title = $value;
                    break;
                case "public":
                    $this->public = $value;
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
            
            // Transform page section into a generic object
            $object->title = $this->title;
            $object->fileName = $this->fileName;
            $object->public = $this->public;
            return $object;
        }
        
        public static function path($fileName) {
            
            // Return relative path to static HTML file
            return $fileName . ".html";
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected function fromObject($object) {
            
            // Reconstruct instance from object argument
            $this->fileName = $object->fileName;
            $this->title = $object->title;
            if ($object->public) {
                $this->public = true;
            }
        }
    }
    
    class IndexHTML {
        
        // 
        // Index HTML
        // ----------
        // When the index is saved, a static HTML file is generated from the index object
        // using an HTML template file.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected static $templatePath = "HTML/Index.html"; // Path to HTML index template file
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function save($index) {
            
            // Encode HTML and save to static HTML file
            file_put_contents(self::path(), self::encode($index));
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected static function path() {
            return "../index.html";
        }
        
        protected static function encode($index) {
            
            // Set HTML meta generator string
            $generator = TITLE . " " . VERSION;
            
            // Parse HTML template into components.*
            $components = explode("<!-- /// -->", file_get_contents(self::$templatePath));
            
            // Concatenate HTML string and swap in page content
            $html = "";
            $html .= ltrim($components[0]);
            if (strlen($index->description) > 0) {
                $html .= ltrim($components[1]);
            }
            $html .= ltrim($components[2]);
            if (strlen($index->description) > 0) {
                $html .= ltrim($components[3]);
            }
            if (count($index->items) > 0) {
                $html .= ltrim($components[4]);
                foreach ($index->items as $item) {
                    if (! $item->public) {
                        
                        // Skip non-public items
                        continue;
                    }
                    $htmlItem = ltrim($components[5], "\r\n\t");
                    $htmlItem = str_replace("<!-- Item path -->", Format::pageURL($item->fileName), $htmlItem);
                    $htmlItem = str_replace("<!-- Item title -->", $item->title, $htmlItem);
                    $html .= $htmlItem; 
                }
                $html .= ltrim($components[6]);
            }
            if (strlen($index->mailAddress) > 0) {
                $html .= ltrim($components[7]);
            }
            if (strlen($index->twitterName) > 0) {
                $html .= ltrim($components[8]);
            }
            $html = str_replace("<!-- Generator -->", $generator, $html);
            $html = str_replace("<!-- Title -->", $index->title, $html);
            $html = str_replace("<!-- Description -->", $index->description, $html);
            $html = str_replace("<!-- Mail URL -->", Format::mailURL($index->mailAddress), $html);
            $html = str_replace("<!-- Mail address -->", Format::mailAddress($index->mailAddress, true), $html);
            $html = str_replace("<!-- Twitter URL -->", Format::twitterURL($index->twitterName), $html);
            $html = str_replace("<!-- Twitter name -->", $index->twitterName, $html);
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