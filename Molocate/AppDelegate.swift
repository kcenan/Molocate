//
//  AppDelegate.swift
//  Molocate

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Bolts
import SDWebImage
import AWSS3
import Fabric
import Crashlytics
import AVFoundation
import Haneke
import QuadratTouch

var DeviceToken:String?
var isRegistered = false
var MoleUserToken: String?
var is4s = false
let debug  = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // [Optional] Power your app with Local Datastore. For more info, go to
        //setStatusBarBackgroundColor()
        
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = false
        if(UserDefaults.standard.bool(forKey: "isRegistered")) {
            isRegistered = true
            DeviceToken = UserDefaults.standard.object(forKey: "DeviceToken") as? String
        }
        
        if(!isRegistered && MoleUserToken != nil && DeviceToken  != nil){
            MolocateAccount.registerDevice({ (data, response, error) in
                
            })
        }
        
        if UserDefaults.standard.object(forKey: "profile_picture") == nil && MoleCurrentUser.profilePic != URL(){
            MolocateAccount.setProfilePictures()
        }
        
        registerForPushNotifications(application)
        
 
        
        //SDImageCache.sharedImageCache().clearMemory()
        //SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().maxMemoryCountLimit = 100

       
        let credentialProvider = AWSCognitoCredentialsProvider(
            regionType: CognitoRegionType,
            identityPoolId: CognitoIdentityPoolId)
        let configuration1 = AWSServiceConfiguration(
            region: DefaultServiceRegionType,
            credentialsProvider: credentialProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration1
        AWSLogger.defaultLogger().logLevel = .None
        // [Optional] Track statistics around application opens.
        let client = Client(clientID: "HKPVG4H554DNGF002XP30XKS1UL1MLX1XLRPZIZVBVMET5HX",
            clientSecret:   "1XXP2QTMACGMW5GSU4GRXZ2PZRLM5G1WEFM5EWQCBWKWCYRG",
            redirectURL:    "molocate://foursquare")
        var configuration = Configuration(client:client)
        configuration.mode = "foursquare" // or "swarm"
        configuration.debugEnabled = false
        configuration.shouldControllNetworkActivityIndicator = true
        Session.setupSharedSessionWithConfiguration(configuration)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            choosedIndex = 3
            NotificationCenter.defaultCenter().post(name: Notification.Name(rawValue: "pushNotification"), object: nil)
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            
        }
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
       
    }
    
    
    
    func application(application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }

    }
   
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //print("Device Token:", tokenString)
        
        DeviceToken = tokenString
        
        if(UserDefaults.standard.bool(forKey: "isRegistered")) {
            if DeviceToken != UserDefaults.standard.object(forKey: "DeviceToken") as? String{
                isRegistered = false
                MolocateAccount.unregisterDevice({ (data, response, error) in
                    MolocateAccount.registerDevice({ (data, response, error) in
                        
                    })
                })
                
               
            }
            
        }
        


    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       // print("Failed to register:", error)
    }
    
    func application(application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        
           // return Session.sharedSession().handleURL(url)
    }
    func application(application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        let windows = UIApplication.shared.windows
        
        for window in windows {
            window.removeConstraints(window.constraints)
        }
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
        if(UserDefaults.standard.bool(forKey: "isRegistered")) {
            isRegistered = true
            DeviceToken = UserDefaults.standard.object(forKey: "DeviceToken") as? String
        }
        
        
        if(DeviceToken == nil) {
            registerForPushNotifications(application)
            if MoleUserToken != nil && DeviceToken != nil && !isRegistered {
                    MolocateAccount.registerDevice({ (data, response, error) in
                     //   print("Success")
                    })
            }
            
        
        }else if !isRegistered && MoleUserToken != nil {
        
            MolocateAccount.registerDevice({ (data, response, error) in
                //print("Success")
            })
        
        }
      
        UIApplication.shared.applicationIconBadgeNumber = 0
 
        NotificationCenter.defaultCenter().post(name: Notification.Name(rawValue: "reloadMain"), object: nil)
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
    
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if (UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.background) {
            
            choosedIndex = 3
            NotificationCenter.defaultCenter().post(name: Notification.Name(rawValue: "pushNotification"), object: nil)
            UIApplication.shared.applicationIconBadgeNumber = 0
          
            
            // go to screen relevant to Notification content
        } else {
           
            // App is in UIApplicationStateActive (running in foreground)
            // perhaps show an UIAlertView
        }
        
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        SDImageCache.sharedImageCache().clearMemory()
        if SDImageCache.sharedImageCache().getDiskCount() > 100 {
            SDImageCache.sharedImageCache().cleanDisk()
        }
        myCache.removeAll()

    }
    
    override func touchesBegan(touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let location :CGPoint = (event?.allTouches?.first?.location(in: self.window))!
        if (location.y > 0) && (location.y < 16) {
            NotificationCenter.defaultCenter().post(name: Notification.Name(rawValue: "scrollToTop"), object: nil)
//            switch (choosedIndex){
//                case 0:
//                case 1:
//                case 2:
//                case 3:
//                default:
//            }
        }
        
        
    }


}

