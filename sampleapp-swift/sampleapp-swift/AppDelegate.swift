//
//  AppDelegate.swift
//  sampleapp-swift
//
//  Created by Devashish on 31/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//


import UIKit
import Applozic


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let alApplocalNotificationHnadler : ALAppLocalNotifications =  ALAppLocalNotifications.appLocalNotificationHandler();
        alApplocalNotificationHnadler.dataConnectionNotificationHandler();
        
        if (ALUserDefaultsHandler.isLoggedIn())
        {
            // Get login screen from storyboard and present it
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LaunchChatFromSimpleViewController") as UIViewController
            self.window?.makeKeyAndVisible();
            self.window?.rootViewController!.presentViewController(viewController, animated:true, completion: nil)
           
        }
        
        if (launchOptions != nil)
        {
            //let dictionary = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
            let dictionary = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
            
            if (dictionary != nil)
            {
                print("launched from push notification")
                let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
                
                let appState: NSNumber = NSNumber(int:0)
                let applozicProcessed = alPushNotificationService.processPushNotification(launchOptions,updateUI:appState)
                if (!applozicProcessed)
                {
                    
                }
            }
        }
    
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("APP_ENTER_IN_BACKGROUND")
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.disconnect()
        NSNotificationCenter.defaultCenter().postNotificationName("APP_ENTER_IN_BACKGROUND", object: nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.connect()
        ALPushNotificationService.applicationEntersForeground()
        print("APP_ENTER_IN_FOREGROUND")
        
        NSNotificationCenter.defaultCenter().postNotificationName("APP_ENTER_IN_FOREGROUND", object: nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        
        ALDBHandler.sharedInstance().saveContext()
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        print("Got token data! \(deviceToken)")
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenString: String = (deviceToken.description as NSString)
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString(" ", withString: "") as String
        
        print(deviceTokenString)
        
        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString)
        {
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceTokenWithCompletion(deviceTokenString, withCompletion: { (response, error) in
                print (response)
            })
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        print("Couldn’t register: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        print("Received notification Completion : \(userInfo)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler
        completionHandler: (UIBackgroundFetchResult) -> Void)
    {
        print("Received notification Completion : \(userInfo)")
        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        alPushNotificationService.notificationArrivedToApplication(application, withDictionary: userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
}

