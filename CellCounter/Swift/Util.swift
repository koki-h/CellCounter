//
//  Util.swift
//  CellCounter
//
//  Created by koki on 2019/10/03.
//  Copyright © 2019 koki. All rights reserved.
//

extension UIColor {
    func encode() -> Dictionary<String, CGFloat>{
        // rgbaの値をDictionaryに入れて返す
        var r = 0.0 as CGFloat
        var g = 0.0  as CGFloat
        var b = 0.0 as CGFloat
        var a = 0.0 as CGFloat
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return ["r":r, "g":g, "b":b, "a":a]
    }

    convenience init?(_ dict:Dictionary<String,Any>?) {
        guard (dict != nil) else {
            return nil
        }
        // Dictionaryに入ったrgbaの値をUIColorにして返す
        let r = CGFloat(dict!["r"] as! Double)
        let g = CGFloat(dict!["g"] as! Double)
        let b = CGFloat(dict!["b"] as! Double)
        let a = CGFloat(dict!["a"] as! Double)
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

