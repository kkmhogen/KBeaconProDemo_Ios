//
//  AppDelegate.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/15.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "mainStoryboard")
        
        self.window!.rootViewController =
            UINavigationController(rootViewController: rootViewController)
        self.window?.makeKeyAndVisible()
       
        return true
    }

}

