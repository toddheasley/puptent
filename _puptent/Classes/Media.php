<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    class Media {
        
        // 
        // Media Manager
        // ----------
        // 
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        protected static $path = "../media"; // Media directory path
        protected static $mode = 0755; // Media directory file permissions
        protected static $allowedFileTypes = array("png", "gif", "jpg", "m4a", "m4v", "mp3", "mov"); // Allowed media file extensions
        protected static $maximumFileSize = 4; // Maximum media file size in megabytes
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function addItem($file) {
            if (! self::isLegal($file)) {
                return;
            }
            
            // Rename uploaded file (with Unix timestamp) and move to media folder.
            $fileName = time() . self::fileExtension($file["name"]);
            move_uploaded_file($tmp_name, self::$path . "/" . $fileName);
            return $fileName;
        }
        
        public static function removeItem($fileName) {
            if (! self::exists($fileName)) {
                return false;
            }
            unlink(self::path($fileName));
            return true;
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
        
        protected static function path($fileName = "") {
            if (! file_exists("Prefix.php")) {
                
                // Working directory is wrong.*
                return;
            }
            if (! file_exists(self::$path) || ! is_dir(self::$path)) {
                
                // Media directory doesn't exist; make a new one.
                mkdir(self::$path);
                chmod(self::$path, 0777);
            }
            
            // Return relative path to media file.
            return self::$path . "/" . $fileName;
        }
        
        protected static function fileExtension($fileName) {
            return pathinfo($file[name], PATHINFO_EXTENSION);
        }
        
        protected static function isLegal($file) {
            if ($file["size"] < 1024 || $file["size"] > (self::maximumFileSize * 1048576) || ! in_array(self::fileExtension($file["name"]))) { 
                
                // File size is too large or file is wrong type.
                return false;
            }
            return true;
        }
        
        // 
        // Notes
        // ----------
        // * Because Pup Tent uses relative paths for simplicity and portability, there's a
        // risk, as in the case of the destruct magic method, that a media directory would
        // be created somewhere unexpected and/or PHP warnings would be raised.
        // 
    }

?>