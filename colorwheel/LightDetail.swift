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
    init() {
        on = false
        reachable = false
        bri = nil
        hue = nil
        sat = nil
        effect = nil
        xy = nil
        ct = nil
        alert = nil
        colormode = nil
        mode = nil
        }
    var on: Bool
    var bri: Int?
    var hue: Int?
    var sat: Int?
    let effect: String?
    let xy: [Double]?
    let ct: Int?
    let alert: String?
    let colormode: String?
    let mode: String?
    let reachable: Bool
}

