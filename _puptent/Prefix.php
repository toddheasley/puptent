<?php

    // 
    // Pup Tent
    //
    // (c) 2011 Todd Heasley
    // 
    
    define("TITLE", "Pup Tent");
    define("VERSION", "1.0");
    define("BASE", "https://github.com/toddheasley/puptent/raw/master/");
    
    function __autoload($className) {
        require("Classes/" . $className . ".php");
    }

?>