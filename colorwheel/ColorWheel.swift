//
//  ColorWheel.swift
//  colorwheel
//
//  Created by Don Browning on 12/3/20.
//

import Foundation


class ColorWheel {

    private let _hueUsername = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    
    enum WheelLights: String {
        case fan1 = "14"
        case fan2 = "15"
        case sixties = "5"
        case desk = "1"
    }
    
    enum ColorEnum: Int {
        case blue = 47104
        case orange = 2645
        case green = 25600
        case red = 0
    }

    func GetColorState(primary: Bool, color: ColorEnum) -> State {
        var s = State()
        s.on = true
        s.sat = 254
        s.bri = (primary ? 254 : 120)
        
        s.hue = color.rawValue
        
        return s
    }
   
    func Start() -> Void {
        
    }
    
    //https://stackoverflow.com/questions/50557431/how-to-do-two-concurrent-api-calls-in-swift-4
    fileprivate func InvokeLights(_ requestLightOne: URLRequest, _ requestLightTwo: URLRequest, _ requestLightThree: URLRequest, _ requestLightFour: URLRequest) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        
        URLSession.shared.dataTask(with: requestLightOne) {data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "no data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String:Any]{
                print(responseJSON)
            }
            print("here Blue")
            DispatchQueue.main.async {
                dispatchGroup.leave()
            }
        }.resume()
        
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestLightTwo) {data, response, error in
            //sleep(1)
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "no data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String:Any]{
                print(responseJSON)
            }
            print("here green")
            DispatchQueue.main.async {
                dispatchGroup.leave()
            }
        }.resume()
        
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestLightThree) {data, response, error in
            //sleep(1)
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "no data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String:Any]{
                print(responseJSON)
            }
            print("here green")
            DispatchQueue.main.async {
                dispatchGroup.leave()
            }
        }.resume()
        
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: requestLightFour) {data, response, error in
            //sleep(1)
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "no data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String:Any]{
                print(responseJSON)
            }
            print("here green")
            DispatchQueue.main.async {
                dispatchGroup.leave()
            }
        }.resume()
        
        
        dispatchGroup.notify(queue: .main){
            print("I'm done with the dispatch group")
        }
    }
    
    func makeColorLightRequest(color: ColorEnum, primary: Bool, light: WheelLights) -> URLRequest? {
        let hc = HueConnection(username: _hueUsername)
        
        let cw = ColorWheel()
        let clr = cw.GetColorState(primary: primary, color: color)

        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(clr)
            
            let urlComps = hc.GetLightState(lightNumber: light.rawValue)
            var request = URLRequest(url: urlComps!.url!)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            return request
            
        }catch {
            print("bad shit happened making the url request")
            return nil
        }
    }
    
    func SetInitialWheelPosition() -> Void {
        let blue = makeColorLightRequest(color: .blue, primary: false, light: .desk)
        let green = makeColorLightRequest(color: .green, primary: false, light: .fan1)
        let orange = makeColorLightRequest(color: .orange, primary: true, light: .fan2)
        let red = makeColorLightRequest(color: .red, primary: false, light: .sixties)
        
        InvokeLights(blue!, green!, orange!, red!)
    
    }
}

