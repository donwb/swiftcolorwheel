//
//  HueConnection.swift
//  colorwheel
//
//  Created by Don Browning on 12/1/20.
//

import Foundation


class HueConnection {
    let rootURL = "http://192.168.1.67"
    let basepath = "/api/"
    var username = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    
    init(username: String){
        self.username = username
    }
    
    
    var BridgeIPAddress: String {
            get {
                let idx = rootURL.lastIndex(of: "/")
                let substr = rootURL.suffix(from: idx!)
                let retVal =  String(substr)
                
                return retVal
            }
        }
    
    func GetBaseURL() -> URLComponents? {
        
        if var urlComps = URLComponents(string: self.rootURL) {
            let appenedPath = basepath + username
            urlComps.path = appenedPath
            
            return urlComps
        }else {
            return nil
        }
    }
    
    func GetLightsURL() -> URLComponents? {
        let urlComps = GetBaseURL()
        
        let existingURL = urlComps?.url?.absoluteString
        let newUrl = existingURL! + "/lights"
        
        let newURLComps = URLComponents(string: newUrl)
        
        return newURLComps
    }
    
    func GetLightURL(lightNumber: String) -> URLComponents? {
        let base = GetBaseURL()
        let existingURL = base?.url?.absoluteString
        
        let newURL = existingURL! + "/lights/" + lightNumber
        let newURLComps = URLComponents(string: newURL)
        
        return newURLComps
    }
    
    func GetLightState(lightNumber: String) -> URLComponents? {
        let base = GetBaseURL()
        let existingURL = base?.url?.absoluteString
        ///lights/14/state"
        let newURL = existingURL! + "/lights/" + lightNumber + "/state"
        let newURLComp = URLComponents(string: newURL)
        
        return newURLComp
        
    }
    
 
}
