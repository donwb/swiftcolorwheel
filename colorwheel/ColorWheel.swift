//
//  ColorWheel.swift
//  colorwheel
//
//  Created by Don Browning on 12/3/20.
//

import Foundation


class ColorWheel {

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
   
}

