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
    let openCv = OpenCVWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        openCv.createCamera(withParentView: imgView)
        openCv.param["slider_value"] = 128
        openCv.param["filter_on"] = true
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
}

