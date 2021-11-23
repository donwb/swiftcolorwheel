// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeValue
struct LightsInfo: Codable {
    let swupdate: Swupdate
    let modelid, swconfigid, productid: String
    let capabilities: Capabilities
    let uniqueid, name: String
    let type: TypeEnum
    let config: Config
    let state: StateClass
    let manufacturername: String
    let productname: String
    let swversion: String
}

// MARK: - Capabilities
struct Capabilities: Codable {
    let streaming: Streaming
    let control: Control
    let certified: Bool
}

// MARK: - Control
struct Control: Codable {
    let mindimlevel: Int?
    let colorgamut: [[Double]]?
    let maxlumen: Int?
    let ct: CT?
    let colorgamuttype: String?
}

// MARK: - CT
struct CT: Codable {
    let min, max: Int
}

// MARK: - Streaming
struct Streaming: Codable {
    let renderer, proxy: Bool
}

// MARK: - Config
// might need to make these strings
struct Config: Codable {
    let direction: Direction
    let function: Function
    let startup: Startup
    let archetype: String
}

enum Direction: String, Codable {
    case downwards = "downwards"
    case omnidirectional = "omnidirectional"
}

enum Function: String, Codable {
    case functional = "functional"
    case mixed = "mixed"
}

// MARK: - Startup
struct Startup: Codable {
    let configured: Bool
    let mode: StartupMode
    let customsettings: Customsettings?
}

// MARK: - Customsettings
struct Customsettings: Codable {
    let bri: Int
}

enum StartupMode: String, Codable {
    case custom = "custom"
    case safety = "safety"
    // Looks like there is a new option now called "powerfail"
    case powerfail = "powerfail"
}



// MARK: - StateClass
struct StateClass: Codable {
    let on: Bool
    let colormode: Colormode?
    let reachable: Bool
    let mode: String
    let bri, sat, ct, hue: Int?
    let xy: [Double]?
    let effect: Alert?
    let alert: Alert
}

enum Alert: String, Codable {
    case none = "none"
    case select = "select"
}

enum Colormode: String, Codable {
    case ct = "ct"
    case xy = "xy"
    case hs = "hs"
}


// MARK: - Swupdate
struct Swupdate: Codable {
    let state: String
    let lastinstall: String
}


enum TypeEnum: String, Codable {
    case colorTemperatureLight = "Color temperature light"
    case dimmableLight = "Dimmable light"
    case extendedColorLight = "Extended color light"
    case onOffPlugInUnit = "On/Off plug-in unit"
}

typealias Welcome = [String: LightsInfo]
