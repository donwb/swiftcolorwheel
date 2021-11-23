//
//  ColorWheel.swift
//  colorwheel
//
//  Created by Don Browning on 12/3/20.
//

import Foundation


class EnhancedColorWheel {

    // MARK: - private members
    private let _hueUsername = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    private var _timer: Timer?
    private var _currentLight = 0
    private var _wheelState = WheelState.idle
    private var _startColor = ValidWheelColors.blue
    private var _theOnlyLight: String
    
    //private var _listeners: [WheelStateChangeListener] = []
    

    init(lightNumber: String) {
        self._theOnlyLight = lightNumber
    }
    enum ValidWheelColors: Int {
        case blue = 47104
        case orange = 2645
        case green = 25600
        case red = 0
    }


    //ColorPickerNotification = "com.codepath.ColorPickerViewController.didPickColor"
    let WheelStartNotification = "com.donwb.WheelStart.started"
    let WheelPositionChanged = "com.donwb.WheelPosition.changed"
    
    // MARK:  - public methods
    
   
    
    /*func addListener(_ listener: WheelStateChangeListener) {
        
        for l in _listeners {
            if l.id == listener.id {return}
        }
        
        _listeners.append(listener)
    }*/
    
    func GetColorState(primary: Bool, color: ValidWheelColors) -> State {
        var s = State()
        s.on = true
        s.sat = 254
        s.bri = (primary ? 254 : 120)
        
        s.hue = color.rawValue
        
        return s
    }
    
    func GetColorState(color: ValidWheelColors) -> State {
        var s = State()
        s.on = true
        s.sat = 254
        //s.bri = (primary ? 254 : 120)
        s.bri = 254
        
        s.hue = color.rawValue
        
        return s
    }
   
    func Start(interval: Double) -> Void {
        _timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        _wheelState = WheelState.running
        
        //_listeners.forEach({ $0.WheelStateDidChange(isRunning: true)})
        
        let ws = ["state": "on"]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"com.donwb.WheelStart.stateChange"), object: nil, userInfo: ws)
    }
    
    func Stop() -> Void {
        _timer?.invalidate()
        _wheelState = WheelState.idle
        
        //_listeners.forEach({ $0.WheelStateDidChange(isRunning: false)})
        let ws = ["state": "off"]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"com.donwb.WheelStart.stateChange"), object: nil, userInfo: ws)
    }
    
    func SetInitialWheelState() -> Void {
        let green = makeColorLightRequest(color: .green)
        let requests = [green!]
        InvokeRequests(requests: requests)
        
    }
    
    // MARK: - private methods
    
    //https://stackoverflow.com/questions/50557431/how-to-do-two-concurrent-api-calls-in-swift-4
    fileprivate func InvokeRequests(requests: [URLRequest]) -> Void {
        let dispatchGroup = DispatchGroup()
        
        for r in requests {
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: r) {data, response, error in
                
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "no data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String:Any]{
                    print(responseJSON)
                }
                DispatchQueue.main.async {
                    dispatchGroup.leave()
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main){
            print("I'm done with the dispatch group")
        }
        
    }
    
    fileprivate func makeColorLightRequest(color: ValidWheelColors) -> URLRequest? {
        let hc = HueConnection(username: _hueUsername)
        
        let cw = EnhancedColorWheel(lightNumber: self._theOnlyLight)
        //let clr = cw.GetColorState(primary: 0, color: color)
        let clr = cw.GetColorState(color: color)

        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(clr)
            
            let urlComps = hc.GetLightState(lightNumber: _theOnlyLight)
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
        
        
        /*
         In this case there is only one light, but there are an array of colors to loop through
         so I need an array of the valid light colors, and each request will iterate
         through that and create a LightRequest
         */
        // The colorset is the way the lights rotate
        
        let validColors = [ValidWheelColors.blue, ValidWheelColors.green, ValidWheelColors.orange, ValidWheelColors.red]
        
        let activeColor = validColors[_currentLight]
        
        print("Idx \(_currentLight) is color \(activeColor)")
        
        
//
//        let ws = ["position": colorSet]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue:WheelPositionChanged), object: nil, userInfo: ws)
  
        var colorRequest = makeColorLightRequest(color: activeColor)
        let requests = [colorRequest!]
        InvokeRequests(requests: requests)
        
//
//        var blue: URLRequest?
//        var green: URLRequest?
//        var orange: URLRequest?
//        var red: URLRequest?
//        let officeLights = [WheelLights.fan2, WheelLights.fan1, WheelLights.sixties, WheelLights.desk]
//
//
//        blue = makeColorLightRequest(color: .blue, primary: (officeLights[colorSet[0]] == WheelLights.fan2), light: officeLights[colorSet[0]])
//        green = makeColorLightRequest(color: .green, primary: officeLights[colorSet[1]] == WheelLights.fan2, light: officeLights[colorSet[1]])
//        orange = makeColorLightRequest(color: .orange, primary: officeLights[colorSet[2]] == WheelLights.fan2, light: officeLights[colorSet[2]])
//        red = makeColorLightRequest(color: .red, primary: officeLights[colorSet[3]] == WheelLights.fan2, light: officeLights[colorSet[3]])
//
//        //InvokeLights(blue!, green!, orange!, red!)
//        let requests = [blue!, green!, orange!, red!]
//        InvokeRequests(requests: requests)
//
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

private extension EnhancedColorWheel{
   enum WheelState {
        //case idle(Info)
        case idle
        //case running(Info)
        case running
   }
}

extension Notification.Name {
    static var enhancedWheelStarted: Notification.Name {
        return .init(rawValue: "Wheel.Running")
    }

    static var enhancedWheelStopped: Notification.Name {
        return .init(rawValue: "Wheel.Idle")
    }

}
/*
private extension ColorWheel {
    func stateDidChange() {
        switch _wheelState {
        case .idle:
            _notificationCenter.post(name: .wheelStopped, object: "Info")
        case .running:
            _notificationCenter.post(name: .wheelStopped, object: "I'm runnign now")
        }
    }
}

@objc protocol WheelStateChangeListener : AnyObject {
    func WheelStateDidChange(isRunning: Bool)
    var id: String {get set}
}


class WheelListener : WheelStateChangeListener {
    var id = UUID().uuidString
    
    func WheelStateDidChange(isRunning: Bool) {
        print("The wheel is running")
    }
    
    
}
*/
//
//  EnhancedColorWheel.swift
//  colorwheel
//
//  Created by Don Browning on 11/23/21.
//
