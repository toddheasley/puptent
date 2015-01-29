//
//  main.swift
//  PupKit
//
//  (c) 2015 @toddheasley
//

import Foundation

let name = NSBundle.mainBundle().executableURL!.lastPathComponent!
let path = String(format:"%@/", NSBundle.mainBundle().bundlePath)
let options = [
    "pitch",
    "build",
    "clean"
]

var error: NSError?

var option = ""
if (Process.arguments.count > 1) {
    option = Process.arguments[1]
}

switch (option) {
case options[0]:
    error = Manager.pitch(path)
case options[1]:
    if let manager = Manager(path: path, error: &error) {
        error = manager.build()
    }
case options[2]:
    if let manager = Manager(path: path, error: &error) {
        error = manager.clean()
    }
default:
    println("\(name) options: \(options)")
    exit(1)
}

if (error != nil) {
    println("\(name) \(option) failed: error \(error!.code) at path \(path)")
    exit(1)
}
println("\(name) \(option) completed")
exit(0)
