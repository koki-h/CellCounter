//
//  ViewController.swift
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imgView: UIImageView!
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
    }
}

