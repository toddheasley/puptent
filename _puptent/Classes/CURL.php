<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    class CURL {
        
        // 
        // PHP cURL Wrapper
        // ----------
        // Convenience methods for making GET and POST requests to remote URLs
        // 
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function get($url) {
            $cURLOptions = array(
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_CONNECTTIMEOUT => 0,
                CURLOPT_URL => $url
            );
            $cURLHandle = curl_init();
            curl_setopt_array($cURLHandle, $cURLOptions);
            $cURLResponse = curl_exec($cURLHandle);
            if (curl_getinfo($cURLHandle, CURLINFO_HTTP_CODE) != "200") {
                
                // Request failed; set response to null.
                $cURLResponse = NULL;
            }
            curl_close($cURLHandle);
            return $cURLResponse;
        }
        
        public static function post($url, $data) {
            $cURLOptions = array(
                CURLOPT_POST => true,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_CONNECTTIMEOUT => 0,
                CURLOPT_URL => $url
            );
            $cURLHandle = curl_init();
            curl_setopt_array($cURLHandle, $cURLOptions);
            curl_setopt($cURLHandle, CURLOPT_POSTFIELDS, $data);
            $cURLResponse = curl_exec($cURLHandle);
            if (curl_getinfo($cURLHandle, CURLINFO_HTTP_CODE) != "200") {
                
                // Request failed; set response to null.
                $cURLResponse = NULL;
            }
            curl_close($cURLHandle);
            return $cURLResponse;
        }
    }

?>