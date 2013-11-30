<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class Format {
        
        // 
        // String Formatting
        // ----------
        // Convenience methods for formatting legal strings
        // 
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function plainText($string) {
            
            // Strip HTML and collapse white space
            $string = trim(strip_tags($string));
            $string = preg_replace('/\s\s+/', " ", $string);
            return trim($string);
        }
        
        public static function inlineHTML($string) {
            
            // Convert line breaks to HTML <br> tags
            $string = nl2br($string, false);
            
            // Strip everything except legal HTML tags.*
            $string = strip_tags($string, "<a><i><b><br>");
            
            // Collapse white space
            $string = preg_replace('/\s\s+/', " ", $string);
            
            // Clean up formatting on remaining HTML tags
            $string = preg_replace("/<(\/?)([a-z][a-z0-9]*)(?:[^>]*(\shref=['\"][^'\"]*['\"]))?[^>]*?(\/?)>/i", "<$1$2$3>", $string);
            $string = str_replace("<br> ", "<br>", $string);
            return $string;
        }
        
        public static function fileName($string) {
            $string = self::plainText($string);
            
            // Transform to lowercase and hyphenate white space
            $string = strtolower($string);
            $string = str_replace(" ", "-", $string);
            return $string;
        }
        
        public static function pageURL($string) {
            return $string . ".html";
        }
        
        public static function mediaURL($string) {
            return "media/" . $string;
        }
        
        public static function mailAddress($string, $encode = false) {
            $string = trim($string);
            if (! strpos($string, "@") || strpos($string, "@") == 0 || strpos($string, "@") > (strlen($string) - 4)) {
                
                // String does not appear to be a valid email address
                $string = "";
            }
            if ($encode) {
                
                // Encode characters in email address.**
                $string = str_replace("r", "&#114", $string);
                $string = str_replace("s", "&#115", $string);
                $string = str_replace("t", "&#116", $string);
                $string = str_replace("l", "&#108", $string);
                $string = str_replace("n", "&#110", $string);
                $string = str_replace("e", "&#101", $string);
                $string = str_replace("@", "&#64", $string);
                $string = str_replace(".", "&#46", $string);
            }
            return $string;
        }
        
        public static function mailURL($string) {
            
            // Format email address for use as complete URL.***
            $string = self::mailAddress($string, true);
            if (strlen($string) > 0) {
                $string = "mailto:" . $string;
            }
            return $string;
        }
        
        public static function twitterName($string) {
            
            // Prepend Twitter name with "@"
            $string = str_replace("@", "", trim($string));
            if (strlen($string) > 0) {
                $string = "@" . $string;
            }
            return $string;
        }
        
        public static function twitterURL($string) {
            
            // Format Twitter account name as a complete URL
            $string = self::twitterName($string);
            $string = str_replace("@", "http://www.twitter.com/", $string);
            return $string;
        }
        
        // 
        // Notes
        // ----------
        // * HTML text blocks in Pup Tent are limited to a small subset of inline HTML
        // elements:
        //     * Linked anchors: "<a href=""></a>"
        //     * Italics: "<i></i>"
        //     * Bolding: "<b></b>"
        //     * Line breaks: "<br>"
        // 
        // ** Encoding some of the characters in an email address as the characters'
        // decimal equivalents will cloak the email address from less sophisticated spam
        // bots. (See: http://en.wikipedia.org/wiki/E-mail_address_harvesting)
        // 
        // *** By default, all email address URLs are encoded with some decimal
        // representations of characters.
        // 
    }

?>