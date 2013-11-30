<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    require_once("Prefix.php");
    
    // 
    // API
    // ----------
    // Pup Tent doesn't include a built-in web-based interface. All functionality is
    // exposed via authenticated HTTP GET and POST calls to this page. GET responses
    // are all formatted as JSON. Where possible, POST data is consolidated into a
    // single JSON-encoded parameter.
    // 
    
    // Set default response values
    $statusCode = 400;
    $json = "";
    
    // Set request type
    $request = "";
    if (isset($_REQUEST["request"])) {
        $request = $_REQUEST["request"];
    }
    
    switch ($request) {
        case "theme":
            
            // 
            // Theme
            // 
            
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // 
                // Action: Change Theme
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "theme",
                //     (JSON) "json" = {
                //         (String) "url" = "http://example.com/theme/page.html"
                //     }
                // 
                
                $object = JSON::decode($_POST["json"]);
                if (isset($object->url) && Theme::fromURL($object->url)) {
                    $statusCode = 200;
                }
            }
            break;
        case "media":
            
            // 
            // Media
            // 
            
            HTTP::authenticate();
            if (isset($_POST["file"])) {
                
                // 
                // Action: Save Media Item
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "media",
                //     (Binary) "file" = [data]
                // Return:
                //     (JSON) {
                //         (String) "fileName" = "1323654118.jpg"
                //     }
                // 
                
                $fileName = Media::addItem($_POST["file"]);
                if (! is_null($fileName)) {
                    $json = JSON::encode($fileName);
                    $statusCode = 200;
                }
            } else if (isset($_POST["fileName"])) {
                
                // 
                // Action: Delete Media Item
                // ----------
                // Method: GET
                // Parameters:
                //     (String) "request" = "media",
                //     (String) "fileName" = "1323654118.jpg"
                // 
                
                if (Media::removeItem($_POST["fileName"])) {
                    $statusCode = 200;
                }
            }
            break;
        case "page":
            
            // 
            // Page
            // 
            
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // 
                // Action: Save Page
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "page",
                //     (JSON) "json" = {
                //         (String) "fileName" = "example-page",
                //         (String) "title" = "Example Page",
                //         (String) "description" = "Text describing page...",
                //         (Array) "sections" = [
                //             {
                //                 (Integer) "type" = 1,
                //                 (String) "text" = "Text describing section...",
                //                 (Array) "media" = [
                //                     "1323654118.jpg"
                //                 ]
                //             }
                //         ]
                //     }
                // 
                
                $object = JSON::decode($_POST["json"]);
                $page = new Page($object->fileName, $_POST["json"]);
                if (! is_null($page->fileName)) {
                    $page->save();
                    $statusCode = 200;
                }
            } else if (isset($_POST["fileName"])) {
                
                // 
                // Action: Delete Page
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "page",
                //     (String) "fileName" = "example-page"
                // 
                
                if (Page::delete($_POST["fileName"])) {
                    $statusCode = 200;
                }
            } else if (isset($_GET["fileName"])) {
                
                // 
                // Action: Get Page
                // ----------
                // Method: GET
                // Parameters:
                //     (String) "request" = "page",
                //     (String) "fileName" = "example-page"
                // Return:
                //     (JSON) {
                //         (String) "fileName" = "example-page",
                //         (String) "title" = "Example Page",
                //         (String) "description" = "Text describing page...",
                //         (Array) "sections" = [
                //             {
                //                 (Integer) "type" = 1,
                //                 (String) "text" = "Text describing section...",
                //                 (Array) "media" = [
                //                     "1323654118.jpg"
                //                 ]
                //             }
                //         ]
                //     }
                // 
                
                if (JSON::exists($_GET["fileName"])) {
                    $json = JSON::read($_GET["fileName"]);
                    $statusCode = 200;
                }
            }
            break;
        case "index":
            
            // 
            // Index
            // 
            
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // 
                // Action: Save Index
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "index",
                //     (JSON) "json" = {
                //         (String) "title" = "Example Web Site",
                //         (String) "description" = "Text describing site...",
                //         (Array) "items" = [
                //             {
                //                 (String) "fileName" = "example-page",
                //                 (String) "title" = "Example Page",
                //                 (Boolean) "public" = false
                //             }
                //         ]
                //     }
                // 
                
                $index = new Index($_POST["json"]);
                $index->save();
                $statusCode = 200;
            } else {
                
                // 
                // Action: Get Index
                // ----------
                // Method: GET
                // Parameters:
                //     (String) "request" = "index"
                // Return:
                //     (JSON) {
                //         (String) "title" = "Example Web Site",
                //         (String) "description" = "Text describing site...",
                //         (Array) "items" = [
                //             {
                //                 (String) "fileName" = "example-page",
                //                 (String) "title" = "Example Page",
                //                 (Boolean) "public" = false
                //             }
                //         ]
                //     }
                // 
                
                if (JSON::exists("index")) { 
                    $json = JSON::read("index", false);
                    $statusCode = 200;
                }
            }
            break;
        case "update":
            
            // 
            // Update
            // 
            
            HTTP::authenticate();
            if (isset($_POST["request"])) {
                
                // 
                // Action: Apply Update
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "update"
                // 
                
                if (Update::apply()) {
                    $statusCode = 200;
                }
            } else {
                
                // 
                // Action: Get Update Availability
                // ----------
                // Method: GET
                // Parameters:
                //     (String) "request" = "update"
                // 
                
                if (Update::exists()) {
                    $statusCode = 200;
                }
            }
            break;
        case "http":
            
            // 
            // HTTP
            // 
            
            if (isset($_POST["json"])) {
                
                // 
                // Action: Save Password 
                // ----------
                // Method: POST
                // Parameters:
                //     (String) "request" = "http",
                //     (JSON) "json" = {
                //         (String) "user" = "jonsmith",
                //         (String) "password" = "p@ssw0rD"
                //     }
                // 
                
                $object = JSON::decode($_POST["json"]);
                if (isset($object->user, $object->password) && HTTP::setPassword($object->user, $object->password)) {
                    $statusCode = 200;
                    break;
                }
            }
            break;
    }
    
    // Send response
    $containsJSON = false;
    if (strlen($json) > 0) {
        $containsJSON = true;
    }
    HTTP::response($statusCode, $containsJSON);
    echo $json;

?>