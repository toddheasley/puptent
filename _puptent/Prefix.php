<?php

    // 
    // Pup Tent
    // Copyright (c) 2011 Todd Heasley
    // 
    
    define("TITLE", "Pup Tent");
    define("VERSION", "1.0");
    
    function __autoload($className) {
        require("Classes/" . $className . ".php");
    }

?>