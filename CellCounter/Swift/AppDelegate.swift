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
    #if arch(i386) || arch(x86_64)
    let DEBUG = true //シミュレーターのときは必ずデバッグモードにする
    #else
    let DEBUG = false
    #endif
    
    var window: UIWindow?
    // OpenCV関連パラメータ
    var openCvParam: Dictionary = ["th_lightness": 128.0,
                                   "th_area_min":0.0,
                                   "th_area_max":4000.0,
                                   "contour_color":UIColor(["r":0.0,"g":1.0,"b":0.0,"a":1.0]) as Any] as [String:Any]

    // 画面表示関連パラメータ
    var screenParam: Dictionary = ["count_color": UIColor(["r":1.0,"g":1.0,"b":1.0,"a":1.0]) as Any] as [String:Any]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        loadCvParams()
        loadScreenParams()
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
        saveCvParams()
        saveScreenParams()
    }

    func loadCvParams() {
        // OpenCV関連の設定をUserDefaultsから読み出す
        // 保存されたパラメータがあれば読み出す
        if let value = UserDefaults.standard.object(forKey: "cv_th_lightness") {
            openCvParam["th_lightness"] = value
        }
        if let value = UserDefaults.standard.object(forKey: "cv_th_area_min") {
            openCvParam["th_area_min"] = value
        }
        if let value = UserDefaults.standard.object(forKey: "cv_th_area_max") {
            openCvParam["th_area_max"] = value
        }
        //配列で保存されていた色設定をUIColorに変換する
        // 境界線の色
        if let value = UserDefaults.standard.dictionary(forKey: "cv_contour_color") {
            openCvParam["contour_color"] = UIColor(value)
        }
    }

    func loadScreenParams() {
        // 画面表示関連の設定をUserDefaultsから読み出す
        // カウントした数字の色
        if let value = UserDefaults.standard.dictionary(forKey: "sc_count_color") {
            screenParam["count_color"] = UIColor(value)
        }
    }

    func saveColorParam(value:UIColor,forKey:String) {
        // UIColorはUserDefaultsに保存できないのでDictionaryに変換する
        UserDefaults.standard.set(value.encode(), forKey: forKey) //パラメータを保存する
    }

    func saveCvParams() {
        // OpenCV関連の設定をUserDefaultsに保存する
        UserDefaults.standard.set(openCvParam["th_lightness"], forKey: "cv_th_lightness")
        UserDefaults.standard.set(openCvParam["th_area_min"], forKey: "cv_th_area_min")
        UserDefaults.standard.set(openCvParam["th_area_max"], forKey: "cv_th_area_max")
        // UIColorはUserDefaultsに保存できないのでDictionaryに変換する
        saveColorParam(value: openCvParam["contour_color"] as! UIColor, forKey: "cv_contour_color")
    }

    func saveScreenParams(){
        // 画面表示関連の設定をUserDefaultsに保存する
        saveColorParam(value: screenParam["count_color"] as! UIColor, forKey: "sc_count_color")
    }
}

