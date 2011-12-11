<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    // 
    // Pup Tent Installer
    // ---------- 
    // To install Pup Tent, copy this script into the desired web server directory (and
    // CHMOD the directory's permissions to 777). When executed, this installer copies
    // the Pup Tent application from Github to the same directory, then deletes itself.
    // 
    
    
    // Define base URL.
    define("BASE", "https://github.com/toddheasley/puptent/raw/master/");
    
    // Set default HTTP respons code.
    $statusCode = 200;
    
    // Read manifest and copy files.
    $manifest = readRemoteFile("Manifest.json");
    if (! isset($manifest->files) || count($manifest->files) < 1) {
        
        // Unable to read manifest.
        $statusCode = 400;
    } else {
        
        // Loop through files and save.
        foreach ($manifest->files as $file) {
            if (saveRemoteFile($file)) {
                continue;
            }
            
            // Unable to copy file.
            $statusCode = 400;
            break;
        }
    }
    
    // Send HTTP response.
    switch ($statusCode) {
        case 200:
                    
            // Send success response.
            header("HTTP/1.1 200 OK");
            header("Status: 200 OK");
            
            // Delete install script.
            unlink(pathinfo($_SERVER["PHP_SELF"], PATHINFO_BASENAME));
            break;
        default:
                    
            // Send error response. 
            header("HTTP/1.1 400 Bad Request");
            header("Status: 400 Bad Request");
            break;
    }
    
    function readRemoteFile($path) {
        $file = copyRemoteFile($path);
        if (! is_null($file)) {
            return json_decode($file);
        }
    }
    
    function saveRemoteFile($path) {
        makeDirectories($path);
        $file = copyRemoteFile($path);
        if (! is_null($file) && file_put_contents($path, $file) > 0) {
            return true;
        }
        return false;
    }
    
    function copyRemoteFile($path) {
        $path = BASE . $path;
        $cURLOptions = array(
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_CONNECTTIMEOUT => 0,
            CURLOPT_URL => $path
        );
        $cURLHandle = curl_init();
        curl_setopt_array($cURLHandle, $cURLOptions);
        $cURLResponse = curl_exec($cURLHandle);
        if (curl_getinfo($cURLHandle, CURLINFO_HTTP_CODE) != "200") {
            $cURLResponse = NULL;
        }
        curl_close($cURLHandle);
        return $cURLResponse;
    }
    
    function makeDirectories($path) {
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

?>