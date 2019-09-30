//
//  ViewController.swift
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var controleView: UIView!
    @IBOutlet weak var slThresholdLight: UISlider!
    @IBOutlet weak var lblLightThreshld: UILabel!

    let openCv = OpenCVWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        openCv.createCamera(withParentView: imgView)
        openCv.param["slider_value"] = 128
        openCv.param["filter_on"] = true
        slThresholdLight.value = Float(openCv.param["slider_value"] as! Int)
        lblLightThreshld.text = String(format:"%3d", openCv.param["slider_value"] as! Int)
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

    @IBAction func threshold_l_changed(_ sender: UISlider) {
        openCv.lockParam() // openCV.paramの値は排他制御する（読み取り側が失敗する可能性があるため）
        defer { openCv.unlockParam() }  // unlock を保証
        openCv.param["slider_value"] = Int(sender.value)
        lblLightThreshld.text = String(format:"%3d", openCv.param["slider_value"] as! Int)
        print(sender.value)
    }


}

