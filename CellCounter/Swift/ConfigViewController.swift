//
//  ConfigViewController.swift
//  CellCounter
//
//  Created by koki on 2019/10/04.
//  Copyright © 2019 koki. All rights reserved.
//

import UIKit
class ConfigViewController: UIViewController,AMColorPickerDelegate {
    let colorPickerViewController = AMColorPickerViewController()
    var btnTouchedDown:UIButton? // ColorPickerを表示するために押されたボタン
    let lockBtnTouchedDown = NSObject() //btnTouchedDownの排他制御用オブジェクト
    var app:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得

    @IBOutlet weak var btnContourColor: UIButton! // 境界線の色設定ボタン
    @IBOutlet weak var btnCountColor: UIButton!   // カウントした数字の色設定ボタン

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerViewController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton(btnContourColor, color: app.openCvParam["contour_color"] as? UIColor ?? UIColor.white)
        setupButton(btnCountColor, color: app.screenParam["count_color"] as? UIColor ?? UIColor.white)
    }

    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        objc_sync_enter(lockBtnTouchedDown)
        // colorPickerで色選択されたときに呼ばれる関数
        guard btnTouchedDown != nil else {
            return
        }
        setupButton(btnTouchedDown!, color: color)
        switch btnTouchedDown {
        case btnContourColor :
            app.openCvParam["contour_color"] = color
        case btnCountColor :
            app.screenParam["count_color"] = color
        case .none:
            break
        case .some(_):
            break
        }
        objc_sync_exit(lockBtnTouchedDown)
    }

    @IBAction func btnDoneDown(_ sender: Any) {
        let preVC = self.presentingViewController as! CameraViewController
        preVC.openCv.setParam(app.openCvParam)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnColorDown(_ sender: UIButton) {
        objc_sync_enter(lockBtnTouchedDown)
        colorPickerViewController.selectedColor = sender.backgroundColor ?? UIColor.white
        btnTouchedDown = sender
        present(colorPickerViewController, animated: true, completion: nil)
        objc_sync_exit(lockBtnTouchedDown)
    }

    func setupButton(_ button:UIButton, color:UIColor) {
        DispatchQueue.main.async {
            button.setTitle(" #" + color.hexStrngWithOpacity() + " ", for: .normal)
            button.backgroundColor = color
            button.tintColor = self.colorMatchedFor(backcolor: color)
        }
    }

    func colorMatchedFor(backcolor: UIColor) -> UIColor{
        // 背景色に合わせた明るさ（黒or白）の文字色を返す
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        backcolor.getRed(&red, green: &green , blue: &blue, alpha: &alpha)
        // red等の値は 0.0 - 1.0 で返るので * 255 して RGB にする
        let delta = ((red * 255 * 299) + ( green * 255 * 587) + (blue * 255 * 114)) / 1000
        // 125 より少なければ背景色は濃い色なので、テキストの色は白く、逆は黒く
        if delta < 125 {
            return UIColor.white
        }else{
            return UIColor.black
        }
    }
}
