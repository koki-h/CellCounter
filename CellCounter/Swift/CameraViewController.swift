//
//  CameraViewController.swift
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
// DONE: 背景色、フォント色、境界線色を別画面で設定できるようにする
// DONE: 背景色を変更すると境界線色に影響する問題を修正する->背景色は黒固定に
// DONE: ダミー画像を使用して処理を実行できるようにする
// DONE: デバッグモードだとカウントの文字色変更が反映されない
// TODO: シミュレーターでもうまく動くようにする（スクリーンショット作成のため）
// TODO: 画面表示をなるべくカッコよく調整する

import UIKit

class CameraViewController: UIViewController, OpenCVWrapperDelegate {
    @IBOutlet var rootView: UIView!                  // 大本のビュー
    @IBOutlet weak var imgView: UIImageView!         // カメラ画像ビュー
    @IBOutlet weak var controleView: UIView!         // 設定スライダー等が載ったビュー
    @IBOutlet weak var slLightThreshold: UISlider!   // 明るさのしきい値を設定するスライダー
    @IBOutlet weak var lblLightThreshold: UILabel!   // 明るさのしきい値を表示するラベル
    @IBOutlet weak var slAreaThreshold: RangeSlider! // 面積のしきい値を設定するスライダー
    @IBOutlet weak var lblAreaThreshold: UILabel!    // 面積のしきい値を表示するラベル
    @IBOutlet weak var dispCounterView: UIView!      // カウントを表示するラベルが載ったビュー
    @IBOutlet weak var lblCellCount: UILabel!        // カウントを表示するラベル

    let openCv = OpenCVWrapper()
    var app:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    var openCVStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        openCv.createCamera(withParentView: imgView)
        openCv.delegate = self
        slLightThreshold.value = Float(app.openCvParam["th_lightness"] as! Double)
        lblLightThreshold.text = String(format:"%3d", Int(slLightThreshold.value))
        slAreaThreshold.lowerValue = app.openCvParam["th_area_min"] as! Double
        slAreaThreshold.upperValue = app.openCvParam["th_area_max"] as! Double
        lblAreaThreshold.text = String(format:"%3d-%3d", Int(slAreaThreshold.lowerValue), Int(slAreaThreshold.upperValue))
        self.lblCellCount.text = "0"
        openCv.setParam(app.openCvParam)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblCellCount.textColor = (app.screenParam["count_color"] as! UIColor) // カウントした数字の色を設定
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if app.DEBUG {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true,
                                              block: {_ in
                                                self.imgView.image = self.openCv.processDummyImage()
            })
            return
        }

        if openCVStarted { //OpenCVの開始は1度だけで良い
            return
        }
        openCv.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openCv.adjustParentViewAspect() // カメラ画像を表示するビューのアスペクト比を調整する
            self.rootView.sendSubviewToBack(self.imgView) //カメラ画像ビューをバックに回す
        }
        openCVStarted = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチした領域のUI要素を表示/非表示切り替えする
        guard let touched = touches.first?.view else {
            return
        }
        //表示表示切り替えするのは controleView と dispCounterViewのみ
        if touched != controleView && touched != dispCounterView {
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
        app.openCvParam["th_lightness"] = Int(sender.value)
        lblLightThreshold.text = String(format:"%3d", Int(sender.value))
        openCv.setParam(app.openCvParam);
    }

    @IBAction func threshold_a_changed(_ sender: RangeSlider) {
        app.openCvParam["th_area_min"] = sender.lowerValue
        app.openCvParam["th_area_max"] = sender.upperValue
        lblAreaThreshold.text = String(format:"%4d-%4d", Int(sender.lowerValue), Int(sender.upperValue))
        openCv.setParam(app.openCvParam);
    }
    
    //ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

