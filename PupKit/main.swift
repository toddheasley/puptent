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

var option = ""
if (Process.arguments.count > 1) {
    option = Process.arguments[1]
}

do {
    switch option {
    case options[0]:
        try Manager.pitch(path)
    case options[1]:
        try Manager(path: path).build()
    case options[2]:
        try Manager(path: path).clean()
    default:
        print("\(name) options: \(options)")
        exit(1)
    }
} catch {
    print("\(name) \(option) failed: error \(error) at path \(path)")
    exit(1)
}

print("\(name) \(option) completed")
exit(0)
