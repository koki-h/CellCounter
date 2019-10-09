//
//  AppDelegate.swift
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // OpenCV関連パラメータ
    var openCvParam: Dictionary = ["th_lightness": 128.0,
                                   "th_area_min":1000.0,
                                   "th_area_max":4000.0,
                                   "contour_color_d":["r":0,"g":0,"b":1.0,"a":1.0]] as [String:Any]

    // 画面表示関連パラメータ
    var screenParam: Dictionary = ["count_color_d": ["r":1,"g":1,"b":1,"a":1.0],
                                   "back_color_d": ["r":0,"g":0,"b":0,"a":1.0]] as [String:Any]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 保存されたパラメータがあれば読み出す
        if let ud_opencv_param = UserDefaults.standard.dictionary(forKey: "OpenCVParam") {
            openCvParam = ud_opencv_param
        }
        if let ud_screen_param = UserDefaults.standard.dictionary(forKey: "ScreenParam") {
            screenParam = ud_screen_param
        }
        //配列で保存されていた色設定をUIColorに変換する
        // 境界線の色
        let contour_color_dict = openCvParam["contour_color_d"] as! Dictionary<String, Any>
        openCvParam["contour_color"] = UIColor(contour_color_dict)
        // カウントした数字の色
        let count_color_dict = screenParam["count_color_d"] as! Dictionary<String, Any>
        screenParam["count_color"] = UIColor(count_color_dict)
        // カウントした数字の色
        let back_color_dict = screenParam["back_color_d"] as! Dictionary<String, Any>
        screenParam["back_color"] = UIColor(back_color_dict)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveParams()
    }

    func saveParams() {
        // 設定をUserDefaultsに保存する
        // UIColorはUserDefaultsに保存できないのでDictionaryに変換する
        let contour_color = openCvParam["contour_color"] as! UIColor
        openCvParam["contour_color"] = nil
        openCvParam["contour_color_d"] = contour_color.encode()
        UserDefaults.standard.set(openCvParam, forKey: "OpenCVParam") //パラメータを保存する
        let count_color = screenParam["count_color"] as! UIColor
        screenParam["count_color"] = nil
        screenParam["count_color_d"] = count_color.encode()
        let back_color = screenParam["back_color"] as! UIColor
        screenParam["back_color"] = nil
        screenParam["back_color_d"] = back_color.encode()
        UserDefaults.standard.set(screenParam, forKey: "ScreenParam") //パラメータを保存する
    }
}

