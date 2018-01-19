//
//  AppDelegate.swift
//  Solidot
//
//  Created by octopus on 05/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var master = MasterController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dataPath = documentsPath.appendingPathComponent("Data")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        window = UIWindow(frame: screenBounds())
        window?.backgroundColor = UIColor.white
        window?.rootViewController = NavigationController(rootViewController: master)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func screenBounds() -> CGRect {
        var rect:CGRect = UIScreen.main.bounds
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            var width:CGFloat
            width = rect.size.width
            rect.size.width = rect.size.height
            rect.size.height = width
        }
        
        return rect
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        SolidotStoryManager.shared.cacheList()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SolidotStoryManager.shared.cacheList()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SolidotStoryManager.shared.cacheList()
    }


}

