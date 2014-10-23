//
//  main.swift
//  PupTent
//
//  (c) 2014 @toddheasley
//

import Foundation

let name = NSBundle.mainBundle().executableURL!.lastPathComponent
let path = String(format:"%@/", NSBundle.mainBundle().bundlePath)
let options = [
    "pitch",
    "build",
    "clean"
]

var option = ""
if (Process.arguments.count > 1) {
    option = Process.arguments[1]
}

if (option == options[0]) {
    if (Manager.siteExistsAtPath(path)) {
        println("\(name) \(option) failed: site already exists at path \(path)")
        exit(1)
    }
    
    var error = Manager.pitchSiteAtPath(path)
    if ((error) != nil) {
        println("\(name) \(option) failed: error \(error!.code) pitching site at path \(path)")
        exit(1)
    }
    
    println("\(name) \(option) completed")
    exit(0)
}

var error: NSError?
let manager = Manager(forSiteAtPath: path, error: &error)
if ((error) != nil) {
    if (error!.code == 260) {
        println("\(name) \(option) failed: site not found at path \(path)")
        exit(1)
    }
    println("\(name) \(option) failed: site manifest at path \(path) contains errors")
    exit(1)
}

if (option == options[1]) {
    manager.build();
    println("\(name) \(option) completed")
    exit(0)
}

if (option == options[2]) {
    manager.clean()
    println("\(name) \(option) completed")
    exit(0)
}

println("\(name) options: \(options)")
exit(0)
