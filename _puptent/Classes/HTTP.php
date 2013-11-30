<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    class HTTP {
        
        // 
        // HTTP Utilities
        // ----------
        // Pup Tent handles API authentication (of a single user/password combination) with
        // basic HTTP authentication and answers requests using a handful of standard HTTP
        // status codes.
        // 
        
        // 
        // ----------
        // Properties
        // 
        
        private static $passwordFile = ".htpasswd"; // Name of hidden static user/password file
        
        // 
        // ----------
        // Public methods
        // 
        
        public static function authenticate() {
            if (! self::passwordIsSet()) {
                
                // Reject all attempts to authenticate until password is set*
                self::response(403);
                exit;
            }
            if (isset($_SERVER["PHP_AUTH_USER"], $_SERVER["PHP_AUTH_PW"]) && self::passwordMatches($_SERVER["PHP_AUTH_USER"], $_SERVER["PHP_AUTH_PW"])) {
                
                // Request is correctly authenticated
                return;
            }
            
            // Prompt client to authenticate
            self::response(401);
            exit;
        }
        
        public static function response($statusCode = 400, $containsJSON = false) {
            if ($containsJSON) {
                
                // Ensure that request is not cached when returning JSON content**
                header("Cache-Control: no-cache, must-revalidate");
                header("Content-type: application/json; charset=utf-8");
            }
            
            // Send appropriate HTTP status***
            switch ($statusCode) {
                case 200:
                    
                    // Send success response
                    header("HTTP/1.1 200 OK");
                    header("Status: 200 OK");
                    break;
                case 400:
                    
                    // Send error response
                    header("HTTP/1.1 400 Bad Request");
                    header("Status: 400 Bad Request");
                    break;
                case 401:
                    
                    // Send unauthorized response
                    header("WWW-Authenticate: Basic");
                    header("HTTP/1.1 401 Unauthorized");
                    header("Status: 401 Unauthorized");
                    break;
                case 403:
                    
                    // Send forbidden response
                    header("HTTP/1.1 403 Forbidden");
                    header("Status: 403 Forbidden");
                    break;
            }
        }
        
        public static function setPassword($user, $password) {
            if (self::passwordIsSet()) {
                HTTP::authenticate();
            }
            
            // Hash new password and to file
            file_put_contents(self::$passwordFile, trim($user) . ":" . crypt(trim($password)));
            return true;
        }
        
        // 
        // ----------
        // Non-public methods
        // 
        
        private static function passwordIsSet() {
            if (file_exists(self::$passwordFile)) {
                return true;
            }
            return false;
        }
        
        private static function passwordMatches($user, $password) {
            if (self::passwordIsSet()) {
                
                // Retrieve hashed password from file
                list($userString, $passwordHash) = explode(":", file_get_contents(self::$passwordFile));
                if ($user == $userString && crypt(trim($password), $passwordHash) == $passwordHash) {
                    return true;
                }
            }
            return false;
        }
        
        // 
        // Notes
        // ----------
        // * The only time password is not set is with a new install.
        // 
        // ** Site data retrieved from Pup Tent's API returns as JSON. Successful posts to
        // the API do not return content with the HTTP response. Similarly, bad requests,
        // whether getting or posting, do not return content with the HTTP response.
        // 
        // *** To keep things simple, Pup Tent returns only two HTTP status codes: one for
        // success (200) and one for failure (400). Other response codes are possible when
        // requests fail to authenticate or, worse, fail to reach the Pup Tent API
        // altogether. The idea behind the binary succeed/fail model is that requests to
        // Pup Tent are so straightforward that responding with a more specific response --
        // or including detailed error messaging as JSON actually complicates debugging
        // when programming against the API.
        // 
    }

?>