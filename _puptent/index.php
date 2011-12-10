<?php

    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    
    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    require_once("Prefix.php");
    
    // 
    // API
    // ----------
    // 
    // 
    
    // Set default response values.
    $statusCode = 400;
    $json = "";
    
    // Set request type.
    $request = "";
    if (isset($_REQUEST["request"])) {
        $request = $_REQUEST["request"];
    }
    
    switch ($request) {
        case "theme":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to theme.
                $object = JSON::decode($_POST["json"]);
                if (isset($object->url) && Theme::fromURL($object->url)) {
                    $statusCode = 200;
                }
            }
            break;
        case "media":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to media.
                
            } else if (isset($_POST["fileName"])) {
                
                // Delete media.
                
            }
            break;
        case "page":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to page.
                $object = JSON::decode($_POST["json"]);
                $page = new Page($object->fileName, $_POST["json"]);
                if (! is_null($page->fileName)) {
                    $page->save();
                    $statusCode = 200;
                }
            } else if (isset($_POST["fileName"])) {
                
                // Delete page.
                if (Page::delete($_POST["fileName"])) {
                    $statusCode = 200;
                }
            } else if (isset($_GET["fileName"])) {
                
                // Get page.
                if (JSON::exists($_GET["fileName"])) {
                    $json = JSON::read($_GET["fileName"]);
                    $statusCode = 200;
                }
            }
            break;
        case "index":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to index.
                $index = new Index($_POST["json"]);
                $index->save();
                $statusCode = 200;
            } else {
                
                // Get index.
                if (JSON::exists("index")) { 
                    $json = JSON::read("index", false);
                    $statusCode = 200;
                }
            }
            break;
        case "import":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to import.
                
            }
            break;
        case "update":
            HTTP::authenticate();
            if (isset($_POST["json"])) {
                
                // Post to update.
                
            }
            break;
        case "http":
            if (isset($_POST["json"])) {
                
                // Post to HTTP.
                $object = JSON::decode($_POST["json"]);
                if (isset($object->user, $object->password) && HTTP::setPassword($object->user, $object->password)) {
                    $statusCode = 200;
                    break;
                }
            }
            break;
    }
    
    // Send response.
    $containsJSON = false;
    if (strlen($json) > 0) {
        $containsJSON = true;
    }
    HTTP::response($statusCode, $containsJSON);
    echo $json;

?>