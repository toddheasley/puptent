<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    class Update {
        
        // 
        // Version Update Manager
        // ----------
        // 
        // 
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function apply() {
            if (is_null($manifest = self::manifest())) {
                return false;
            }
            
            // Loop through files and save.
            foreach ($manifest->files as $file) {
                if (self::save($file)) {
                    continue;
                }
                
                // Unable to copy/save file; abort update.
                return false;
            }
            return true;
        }
        
        public static function exists() {
            if (! is_null($manifest = self::manifest()) && VERSION != $manifest->version) {
                
                // Update is available.
                return true;
            }
            return false;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected static function manifest() {
            
            // Fetch remote manifest and decode.
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
                    
                    // Directory already exists.
                    continue;
                }
                
                // Make directory and set permissions.
                mkdir($path);
                chmod($path, 0777);
            }
        }
    }

?>