//
//  ViewController.swift
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//
// DONE: 輪郭線のカウントを画面に表示する
// TODO: 輪郭線面積の上下しきい値を設定できるようにする
// TODO: しきい値の範囲を外れる面積の輪郭線をカウントから除外するようにする
// TODO: パラメータを変更時に自動的に保存するようにする
// TODO: 起動時に保存したパラメータを読み出すようにする
// TODO: 画面表示をなるべくカッコよく調整する

import UIKit

class ViewController: UIViewController, OpenCVWrapperDelegate {
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var controleView: UIView!
    @IBOutlet weak var dispCounterView: UIView!
    @IBOutlet weak var slThresholdLight: UISlider!
    @IBOutlet weak var lblLightThreshld: UILabel!
    @IBOutlet weak var lblCellCount: UILabel!

    let openCv = OpenCVWrapper()
    var openCvParam: Dictionary = ["slider_value": 128]

    override func viewDidLoad() {
        super.viewDidLoad()
        openCv.createCamera(withParentView: imgView)
        openCv.delegate = self
        slThresholdLight.value = Float(openCvParam["slider_value"]!)
        lblLightThreshld.text = String(format:"%3d", openCvParam["slider_value"]!)
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
        if controleView.alpha == 1 {
            controleView.alpha = 0
        } else {
            controleView.alpha = 1
        }
    }

    func didProcessImage(_ result: [AnyHashable : Any]) {
        DispatchQueue.main.async {
            self.lblCellCount.text = String(result["contours_count"] as! Int)
        }
    }

    @IBAction func threshold_l_changed(_ sender: UISlider) {
        openCvParam["slider_value"] = Int(sender.value)
        lblLightThreshld.text = String(format:"%3d", openCvParam["slider_value"]!)
        openCv.setParam(openCvParam);
    }
}

