<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class JSON {
        
        // 
        // JSON Utilities
        // ----------
        // Pup Tent stores everything as static JSON files. Reading and writing these JSON
        // files is abstracted away behind the methods in this class.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected static $path = "JSON"; // JSON directory path
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function save($fileName, $object) {
            file_put_contents(self::path($fileName), self::encode($object));
        }
        
        public static function read($fileName, $decode = true) {
            if (! self::exists($fileName)) {
                return;
            }
            $fileContents = file_get_contents(self::path($fileName));
            if ($decode) {
                $fileContents = self::decode($fileContents);
            }
            return $fileContents;
        }
        
        public static function encode($object) {
            return json_encode($object);
        }
        
        public static function decode($json) {
            return json_decode($json);
        }
        
        public static function delete($fileName) {
            if (file_exists(self::path($fileName))) {
                unlink(self::path($fileName));
            }
        }
        
        public static function exists($fileName) {
            if (file_exists(self::path($fileName))) {
                return true;
            }
            return false;
        }
        
        public static function path($fileName) {
            if (! file_exists("Prefix.php")) {
                
                // Working directory is wrong*
                return;
            }
            if (! file_exists(self::$path) || ! is_dir(self::$path)) {
                
                // JSON directory doesn't exist; make a new one
                mkdir(self::$path);
                chmod(self::$path, 0777);
            }
            
            // Return relative path to static JSON file
            return self::$path . "/" . $fileName . ".json";
        }
        
        // 
        // Notes
        // ----------
        // * Because Pup Tent uses relative paths for simplicity and portability, there's a
        // risk, as in the case of the destruct magic method, that a JSON directory would
        // be created somewhere unexpected and/or PHP warnings would be raised.
        // 
    }

?>