//
//  AppDelegate.swift
//  LYFormView
//
//  Created by LiuYang on 2017/11/8.
//  Copyright © 2017年 LiuYang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = UIColor.white
        
        let VC = ViewController()
        
        window?.rootViewController = VC
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

