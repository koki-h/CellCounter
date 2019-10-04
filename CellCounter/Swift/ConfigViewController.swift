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
    var app:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得

    @IBOutlet weak var btnContourColor: UIButton! // 境界線の色設定ボタン

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerViewController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton(btnContourColor, color: app.openCvParam["contour_color"] as? UIColor ?? UIColor.white)
    }

    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        // colorPickerで色選択されたときに呼ばれる関数
        guard btnTouchedDown != nil else {
            return
        }
        setupButton(btnTouchedDown!, color: color)
        switch btnTouchedDown {
        case btnContourColor :
            app.openCvParam["contour_color"] = color
        case .none:
            break
        case .some(_):
            break
        }
    }

    @IBAction func btnDoneDown(_ sender: Any) {
        let preVC = self.presentingViewController as! CameraViewController
        preVC.openCv.setParam(app.openCvParam)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnContourColorDown(_ sender: UIButton) {
        // TODO 今後作成する他の色設定と干渉しないように排他制御を行う（colorPickerは一つしか無いので）
        colorPickerViewController.selectedColor = sender.backgroundColor ?? UIColor.white
        btnTouchedDown = sender
        present(colorPickerViewController, animated: true, completion: nil)
    }

    func setupButton(_ button:UIButton, color:UIColor) {
        button.backgroundColor = color
        button.tintColor = colorMatchedFor(backcolor: color)
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
