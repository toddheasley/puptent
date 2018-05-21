import Foundation

enum Option: String {
    case pitch, build, clean
}

let name: String = Bundle.main.executableURL!.lastPathComponent
let path: String = "\(Bundle.main.bundlePath)/"

guard let option: Option = Option(rawValue: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "") else {
    print("\(name) options: \(Option.pitch.rawValue), \(Option.build.rawValue), \(Option.clean.rawValue)")
    exit(1)
}

do {
    switch option {
    case .pitch:
        try Manager.pitch(path: path)
    case .build:
        try Manager(path: path).build()
    case .clean:
        try Manager(path: path).clean()
    }
    print("\(name) \(option.rawValue) completed")
    exit(0)
} catch {
    print("\(name) \(option) failed: error \(error) at path \(path)")
    exit(1)
}
