//
//  AppDelegate.swift
//  frameworktest
//
//  Created by Allan Mageto on 24/05/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
// IKIA9A10A4795B5C94BBCF97300958DB16598C1C48AB
// jdl3sGVBnSUVo8xFreD1l9etqYiLkXwnm9V2d1zgd4A=

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    var navigationController: UINavigationController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            let mainVC = ViewController()
            navigationController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

