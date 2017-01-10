//
//  AppDelegate.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        //OneSignal.setLogLevel(.LL_ERROR, visualLevel: .LL_DEBUG)
        //OneSignal.initWithLaunchOptions(launchOptions, appId: "318d5792-0be6-4093-b776-3012cf91fd7a")
        //OSNotificationDisplayType.none
        /*OneSignal.initWithLaunchOptions(launchOptions, appId: "318d5792-0be6-4093-b776-3012cf91fd7a", handleNotificationReceived: ({ (notification) in
            notification?.displayType = .none
        }), handleNotificationAction: nil, settings: nil)
        */
       
        OneSignal.initWithLaunchOptions(launchOptions, appId: "318d5792-0be6-4093-b776-3012cf91fd7a", handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification?.payload.notificationID) - \(notification?.payload.title)")
        }, handleNotificationAction: { (result) in
            
            // This block gets called when the user reacts to a notification received
            let payload = result?.notification.payload
            var fullMessage = payload?.title
            
            //Try to fetch the action selected
            if let additionalData = payload?.additionalData, let actionSelected = additionalData["actionSelected"] as? String {
                fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
            }
            print(fullMessage ?? "FULL MESSAGE")
        }, settings:  [kOSSettingsKeyAutoPrompt : true, kOSSettingsKeyInFocusDisplayOption : OSNotificationDisplayType.none.rawValue])
        
        if let alreadySignedIn = FIRAuth.auth()?.currentUser {
            if alreadySignedIn.isEmailVerified && UserDefaults.standard.bool(forKey: "loggedIn"){
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
                self.window?.rootViewController = vc
               
            }
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationCategories { (categories) in
                let myAction = UNNotificationAction(identifier: "action0", title: "Hit Me!", options: .foreground)
                let myCategory = UNNotificationCategory(identifier: "myOSContentCategory", actions: [myAction], intentIdentifiers: [], options: .customDismissAction)
                let mySet = NSSet(array: [myCategory]).addingObjects(from: categories) as! Set<UNNotificationCategory>
                UNUserNotificationCenter.current().setNotificationCategories(mySet)
            }
        }

        return true
    }

    
    

}




