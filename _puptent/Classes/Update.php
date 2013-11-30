<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class Update {
        
        // 
        // Version Update Manager
        // ----------
        // As new versions of Pup Tent become available*, this class provides functionality
        // for existing, in-use versions of Pup Tent to check for the availability of new
        // versions and update** to the current version. 
        // 
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function apply() {
            if (is_null($manifest = self::manifest())) {
                return false;
            }
            
            // Loop through files and save
            foreach ($manifest->files as $file) {
                if (self::save($file)) {
                    continue;
                }
                
                // Unable to copy/save file; abort update
                return false;
            }
            return true;
        }
        
        public static function exists() {
            if (! is_null($manifest = self::manifest()) && VERSION != $manifest->version) {
                
                // Update is available
                return true;
            }
            return false;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected static function manifest() {
            
            // Fetch remote manifest and decode
            $manifest = JSON::decode(CURL::get(BASE . "Manifest.json"));
            if (isset($manifect->title, $manifest->version, $manifest->files) && count($manifest->files) > 0) {
                return $manifest;
            }
            
        }
        
        protected static function save($path) {
            makeDirectories($path);
            $file = CURL::get(BASE . $path);
            if (! is_null($file) && file_put_contents($path, $file) > 0) {
                return true;
            }
            return false;
        }
        
        protected static function makeDirectories($path) {
            $directories = explode("/", pathinfo($path, PATHINFO_DIRNAME));
            $path = "";
            foreach ($directories as $directory) {
                $path .= $directory . "/";
                if (file_exists($path) && is_dir($path)) {
                    
                    // Directory already exists
                    continue;
                }
                
                // Make directory and set permissions
                mkdir($path);
                chmod($path, 0777);
            }
        }
        
        // 
        // Notes
        // ----------
        // * Pup Tent is hosted on Github. Each new version of Pup Tent includes a manifest
        // that contains the current version number and a list of all application files.
        // 
        // ** Updates are performed by copying application files directly from the Github
        // master and overwriting the existing local application files. Updates do not
        // overwrite or modify existing JSON, HTML or media content files.
        // 

    }

?>