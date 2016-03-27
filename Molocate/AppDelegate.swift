//
//  AppDelegate.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.11.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Bolts
import QuadratTouch
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // [Optional] Power your app with Local Datastore. For more info, go to
      
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().maxMemoryCountLimit = 20
        
        
        // [Optional] Track statistics around application opens.
        let client = Client(clientID: "HKPVG4H554DNGF002XP30XKS1UL1MLX1XLRPZIZVBVMET5HX",
            clientSecret:   "1XXP2QTMACGMW5GSU4GRXZ2PZRLM5G1WEFM5EWQCBWKWCYRG",
            redirectURL:    "molocate://foursquare")
        var configuration = Configuration(client:client)
        configuration.mode = "foursquare" // or "swarm"
        configuration.shouldControllNetworkActivityIndicator = true
        Session.setupSharedSessionWithConfiguration(configuration)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
            return Session.sharedSession().handleURL(url)
    }
    
    
    //Make sure it isn't already declared in the app delegate (possible redefinition of func error)
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

