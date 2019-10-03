//
//  ViewController.swift
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//
// DONE: 輪郭線のカウントを画面に表示する
// DONE: 輪郭線面積の上下しきい値を設定できるようにする
// DONE: しきい値の範囲を外れる面積の輪郭線をカウントから除外するようにする
// DONE: パラメータを変更時に自動的に保存するようにする
// DONE: 起動時に保存したパラメータを読み出すようにする
// TODO: 画面表示をなるべくカッコよく調整する
// TODO: 背景色、フォント色、境界線色を別画面で設定できるようにする

import UIKit

class ViewController: UIViewController, OpenCVWrapperDelegate {
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var controleView: UIView!
    @IBOutlet weak var dispCounterView: UIView!
    @IBOutlet weak var slLightThreshold: UISlider!
    @IBOutlet weak var lblLightThreshold: UILabel!
    @IBOutlet weak var slAreaThreshold: RangeSlider!
    @IBOutlet weak var lblAreaThreshold: UILabel!
    @IBOutlet weak var lblCellCount: UILabel!

    let openCv = OpenCVWrapper()
    var openCvParam: Dictionary = ["th_lightness": 128,
                                   "th_area_min":1000,
                                   "th_area_max":4000] {
        didSet {
            UserDefaults.standard.set(openCvParam, forKey: "OpenCVParam")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        openCv.createCamera(withParentView: imgView)
        openCv.delegate = self
        if let ud_opencv_param = UserDefaults.standard.dictionary(forKey: "OpenCVParam") {
            openCvParam = ud_opencv_param as! [String : Int]
        }
        slLightThreshold.value = Float(openCvParam["th_lightness"]!)
        lblLightThreshold.text = String(format:"%3d", openCvParam["th_lightness"]!)
        slAreaThreshold.lowerValue = Double(openCvParam["th_area_min"]!)
        slAreaThreshold.upperValue = Double(openCvParam["th_area_max"]!)
        lblAreaThreshold.text = String(format:"%3d-%3d", openCvParam["th_area_min"]!, openCvParam["th_area_max"]!)
        self.lblCellCount.text = "0"
        openCv.setParam(openCvParam)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openCv.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openCv.adjustParentViewAspect() // カメラ画像を表示するビューのアスペクト比を調整する
        }
        rootView.sendSubviewToBack(imgView)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチした領域のUI要素を表示/非表示切り替えする
        guard let touched = touches.first?.view else {
            return
        }
        for subview in touched.subviews {
            if subview.alpha == 1 {
                subview.alpha = 0
            } else {
                subview.alpha = 1
            }
        }
    }

    func didProcessImage(_ result: [AnyHashable : Any]) {
        DispatchQueue.main.async {
            self.lblCellCount.text = String(result["contours_count"] as! Int)
        }
    }

    @IBAction func threshold_l_changed(_ sender: UISlider) {
        openCvParam["th_lightness"] = Int(sender.value)
        lblLightThreshold.text = String(format:"%3d", openCvParam["th_lightness"]!)
        openCv.setParam(openCvParam);
    }

    @IBAction func threshold_a_changed(_ sender: RangeSlider) {
        openCvParam["th_area_min"] = Int(sender.lowerValue)
        openCvParam["th_area_max"] = Int(sender.upperValue)
        lblAreaThreshold.text = String(format:"%4d-%4d", openCvParam["th_area_min"]!, openCvParam["th_area_max"]!)
        openCv.setParam(openCvParam);
    }
}

