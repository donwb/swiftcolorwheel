// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct LightDetail: Codable {
    let state: State
    let swupdate: Swupdate
    let type, name, modelid, manufacturername: String
    let productname: String
    let capabilities: Capabilities
    let config: Config
    let uniqueid, swversion, swconfigid, productid: String
}

// MARK: - State
struct State: Codable {
    let on: Bool
    let bri, hue, sat: Int
    let effect: String
    let xy: [Double]
    let ct: Int
    let alert, colormode, mode: String
    let reachable: Bool
}

