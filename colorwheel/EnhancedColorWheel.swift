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
    private var _activeLightIndex = 0
    private var _wheelState = WheelState.idle
    private var _startColor = ValidWheelColors.gold
    private var _theOnlyLight: String
    
    //private var _listeners: [WheelStateChangeListener] = []
    

    init(lightNumber: String) {
        self._theOnlyLight = lightNumber
    }
    enum ValidWheelColors: Int {
        case gold = 9426
        case orange = 2645
        case green = 25600
        case red = 0
    }
    
    enum WheelBrightness: Int {
        case dim = 50
        case medium = 128
        case bright = 245
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
        // I'm in a hurry, but this should be passed in and configurable
        s.bri = WheelBrightness.medium.rawValue
        
        s.hue = color.rawValue
        
        return s
    }
   
    func Start(interval: Double) -> Void {
        _timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        _wheelState = WheelState.running
        
        //_listeners.forEach({ $0.WheelStateDidChange(isRunning: true)})
        
        let ws = ["state": "on"]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"com.donwb.SingleWheelStart.stateChange"), object: nil, userInfo: ws)
    }
    
    func Stop() -> Void {
        _timer?.invalidate()
        _wheelState = WheelState.idle
        
        //_listeners.forEach({ $0.WheelStateDidChange(isRunning: false)})
        let ws = ["state": "off"]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"com.donwb.SingleWheelStart.stateChange"), object: nil, userInfo: ws)
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
        
        let validColors = [ValidWheelColors.gold, ValidWheelColors.red, ValidWheelColors.green, ValidWheelColors.orange]
        
        let activeColor = validColors[_activeLightIndex]
        
        print("Idx \(_activeLightIndex) is color \(activeColor)")
        
        

        let ws = ["position": _activeLightIndex]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:WheelPositionChanged), object: nil, userInfo: ws)
  
        var colorRequest = makeColorLightRequest(color: activeColor)
        let requests = [colorRequest!]
        InvokeRequests(requests: requests)

        if _activeLightIndex < 3 {
            _activeLightIndex += 1
        } else {
            _activeLightIndex = 0
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
        return .init(rawValue: "SingleWheel.Running")
    }

    static var enhancedWheelStopped: Notification.Name {
        return .init(rawValue: "SingleWheel.Idle")
    }

}
