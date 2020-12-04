//
//  ColorWheel.swift
//  colorwheel
//
//  Created by Don Browning on 12/3/20.
//

import Foundation


class ColorWheel {

    // MARK: - private members
    private let _hueUsername = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    private var _timer: Timer?
    private var _currentLight = 0
    
    // MARK: - enums
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

    // MARK:  - public methods
    
    func GetColorState(primary: Bool, color: ColorEnum) -> State {
        var s = State()
        s.on = true
        s.sat = 254
        s.bri = (primary ? 254 : 120)
        
        s.hue = color.rawValue
        
        return s
    }
   
    func Start(interval: Double) -> Void {
        _timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func Stop() -> Void {
        _timer?.invalidate()
    }
    
    func SetInitialWheelPosition() -> Void {
        let blue = makeColorLightRequest(color: .blue, primary: false, light: .desk)
        let green = makeColorLightRequest(color: .green, primary: false, light: .fan1)
        let orange = makeColorLightRequest(color: .orange, primary: true, light: .fan2)
        let red = makeColorLightRequest(color: .red, primary: false, light: .sixties)
        
        InvokeLights(blue!, green!, orange!, red!)
    
    }
    
    // MARK: - private methods
    
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
    
    fileprivate func makeColorLightRequest(color: ColorEnum, primary: Bool, light: WheelLights) -> URLRequest? {
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
    

    

    
    @objc func fireTimer() {
        print("timer fired")
        
        // there are 4 colors, which rotate amongst 4 different lights
        // the colors are fixed, and the lights rotate via the index
        // that is set by the timer firing.
        // the primary light is always "fan2"
        // The colorset is the way the lights rotate
        
        let colorSet = colorPosition(idx: _currentLight)
        var blue: URLRequest?
        var green: URLRequest?
        var orange: URLRequest?
        var red: URLRequest?
        let officeLights = [WheelLights.fan2, WheelLights.fan1, WheelLights.sixties, WheelLights.desk]
        
        
        blue = makeColorLightRequest(color: .blue, primary: (officeLights[colorSet[0]] == WheelLights.fan2), light: officeLights[colorSet[0]])
        green = makeColorLightRequest(color: .green, primary: officeLights[colorSet[1]] == WheelLights.fan2, light: officeLights[colorSet[1]])
        orange = makeColorLightRequest(color: .orange, primary: officeLights[colorSet[2]] == WheelLights.fan2, light: officeLights[colorSet[2]])
        red = makeColorLightRequest(color: .red, primary: officeLights[colorSet[3]] == WheelLights.fan2, light: officeLights[colorSet[3]])
        
        InvokeLights(blue!, green!, orange!, red!)
        
        //_currentLight = _currentLight < 3 ? _currentLight += 1 : _currentLight = 0
        if _currentLight < 3 {
            _currentLight += 1
        } else {
            _currentLight = 0
        }
        
        
    }
    
    fileprivate func colorPosition(idx: Int) -> [Int]{
        // i'm sure there's a better way, but this simulates the
        // roatation of the wheel, moving the slots one to the left
        
        switch idx {
        case 0:
            return [0, 1, 2, 3]
        case 1:
            return [1, 2, 3, 0]
        case 2:
            return [2, 3, 0, 1]
        case 3:
            return [3, 0, 1, 2]
        default:
            return [0, 1, 2, 3]
        }
        
    }
}

