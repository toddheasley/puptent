<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class Theme {
        
        // 
        // Theme Manager
        // ----------
        // A Pup Tent "theme" has two components: a single JavaScript file and a single
        // stylesheet file. Themes can be downloaded from any URL, creating a mechanism by
        // which people can make and share their own themes.*
        // 
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function fromURL($url) {
            if (substr($url, -1) != "/") {
                $url = pathinfo($url, PATHINFO_DIRNAME) . "/";
            }
            
            // Retrieve theme files from remote URL
            $themeCSS = CURL::get($url . "theme.css");
            $themeJS = CURL::get($url . "theme.js");
            if (is_null($themeCSS) || is_null($themeJS)) {
                
                // One or more theme components was not found; cancel theme update
                return false;
            }
            
            // Write theme files to public site
            file_put_contents(self::path("theme.css"), $themeCSS);
            file_put_contents(self::path("theme.js"), $themeJS);
            return true;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        protected static function path($fileName) {
            
            // Return relative path to theme file in public site directory
            return "../" . $fileName;
        }
        
        // 
        // Notes
        // ----------
        // * By design, Pup Tent favors simplicity over security; because themes include
        // JavaScript, theme authors could introduce code into a theme that would, for
        // example, provide theme usage statistics to the theme author.
        // 
    }

?>