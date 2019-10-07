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

    func hexStrngWithOpacity() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        let opacity:Int = Int(a * 100)
        return String(format: "%06x (%d)", rgb, opacity) as String
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

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}
