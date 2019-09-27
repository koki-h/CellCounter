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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openCv.start()
    }


}

