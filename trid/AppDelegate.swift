//
//  AppDelegate.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseRemoteConfig
import FirebaseAnalytics
import PureLayout
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift
import AppAuth
import SwiftHTTP
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate ,MessagingDelegate{
    static var deviceToken : String?

    public var window: UIWindow?
    var navigation : UINavigationController!
    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    
    // Google maps key
    let googleMapsApiKey = "AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg"

    //GMSServices.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
    fileprivate func setRemoteNotfactionSettings(_ application: UIApplication) {
        print("Im here in notfaction fire base function")
        if #available(iOS 10.0, *){
            //notificationContent.sound = UNNotificationSound(named: "out.mp3")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
                
                if err != nil {
                    print("Firebase Error: \(String(describing: err))")
                }else {
                    print("Successful Authorization 1")
                    
                    UNUserNotificationCenter.current().delegate = self
                   

                    DispatchQueue.main.async {
                        //UNNotificationSound.sound = UNNotificationSound(named: "out.caf")
                        UIApplication.shared.registerForRemoteNotifications()
                        application.registerForRemoteNotifications()
                        Messaging.messaging().delegate = self

                        Messaging.messaging().shouldEstablishDirectChannel = true
                    }
                }
            }
            
        }else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            print("Successful Authorization 2")
        }
        // setUpSocket()
        
        application.registerForRemoteNotifications()
        
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("REMOTE-LOG \(remoteMessage.appData)")
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("Im here in notfaction fire base function 11")
        
        print("notification remoteMessage 2 ")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                Messaging.messaging().subscribe(toTopic: "IOS-SYSTEM"){error in
                    print("Subscribed-to-topic")
                }
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                Messaging.messaging().subscribe(toTopic: "IOS-SYSTEM"){error in
                    print("Subscribed-to-topic")
                }
                print("Remote instance ID token: \(result.token)")
            }
        }
        print("im in  \(fcmToken)")
       }
    func ConnectToFcm(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppDelegate.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        debugPrint("Device token: \(AppDelegate.deviceToken ?? "nil")")
        
    }
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Check installed or upgrade
        checkAppUpgrade()
        getAccessToken()
        setRemoteNotfactionSettings(application)
        getCurrancy()

        // keyboard manager
        //IQKeyboardManager.shared.enable = true
        
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
       
        // window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // navigation
        let splash = SplashViewController(nibName: "SplashViewController", bundle: nil)
        navigation = UINavigationController(rootViewController: splash)
        navigation.isNavigationBarHidden = true
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
        
        // status color
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Google map
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        // Dropdown listening keyboard
        DropDown.startListeningToKeyboard()
        
        // Start checking database connection
        TridService.shared.listenConnectionCheck = {online in
            TridService.shared.listenConnectionCheck = nil
        }
        
//        // Register Push notification
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        application.registerForRemoteNotifications()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)


        }
  
    func checkAppUpgrade() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        debugPrint(currentVersion ?? "", versionOfLastRun ?? "")
        if versionOfLastRun == nil {
            // First start after installing the app
        } else if versionOfLastRun != currentVersion {
            MeasurementHelper.updatedVersion(currentVersion ?? "")
            // App was updated since last run
            if versionOfLastRun == "1.0.1" && currentVersion == "1.2.0" {
                PurchaseManager.savePurchasedAllItem()
            }
        } else {
            // nothing changed
        }
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().shouldEstablishDirectChannel = true
        ConnectToFcm()
        debugPrint("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ConnectToFcm()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("Im here in notfaction fire base function 5")
        
        print("Sdk facebook im before sourceApplication ")
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    // MARK: - Google delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint(error.localizedDescription)
            NotificationCenter.default.post(name: NotificationKey.signInError, object: error)
            return
        }
        // ...
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        // login
     //   firebaseLoginWith(credential: credential, info: SignInInfo.makeGoogle(idToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!))
    }
    func getAccessToken() {
        let defaults = UserDefaults.standard
        let access_token = defaults.string(forKey: "access_token")
        let expires_in = defaults.object(forKey: "expires_in")
        let calendar = Calendar.current
        let firstDownload = defaults.string(forKey: "first_download")
        let date = calendar.date(byAdding: .second, value: 0, to : Date())
        print("current date is \(date) and exp date is \(expires_in)")
        
        if access_token == nil
        {
            
            print("Token is nil")
            getTokenReuqest()
        }
        else
        {
            if (expires_in as! Date) > date! {
                print("Token is not  nil and date < from exp date")
                if firstDownload != nil && firstDownload == "true"
                {
                    
                }
                else{
                    firstDownloadFunc()
                }
                //
                
            }
            else
            {
                print("Token is not  nil and date > from exp date")
                getTokenReuqest()
                
            }
        }
    }
    func setToUserDefaults(value: Any?, key: String){
        if value != nil {
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
        }
        else{
            let defaults = UserDefaults.standard
            defaults.set("no value", forKey: key)
        }
        
        
    }
    func firstDownloadFunc() {
        var params: [String: Any] = [:]
        let deviceToken = UIDevice.current.identifierForVendor!.uuidString
        let countryName = Locale.current.localizedString(forRegionCode: Locale.current.regionCode!)
        params = ["device_type": "ios", "device_id": deviceToken, "local": countryName]
        HTTP.POST(ApiRouts.Api + "/downloads", parameters: params) { response in
            if response.error != nil {
                print("error \(response.error)")
                return
            }
            do {
                
                print("Discription is \(response.description)")
                DispatchQueue.main.async {
                    self.setToUserDefaults(value: "true", key: "first_download")
                    print("Discription is true")
                    
                }
                
            }
            catch {
                
            }
        }
    }
    func getTokenReuqest() {
        var params: [String: Any] = [:]
        params = ["grant_type": "client_credentials", "client_id": "2", "scope": "", "client_secret": "YErvt0T9iPupWJfLOChPSkJKcqZKZhP0DHntkcTL"]
        let url: String = ApiRouts.Web + "/oauth/token"
        HTTP.POST(url, parameters: params) { response in
            if response.error != nil {
                print("error \(response.error)")
                return
            }
            do {
                let accessToken : AccessToken =  try JSONDecoder().decode(AccessToken.self, from: response.data)
                let calendar = Calendar.current
                let date = calendar.date(byAdding: .second, value: accessToken.expires_in!, to : Date())
                let defaults = UserDefaults.standard
                self.setToUserDefaults(value: accessToken.access_token!, key: "access_token")
                self.setToUserDefaults(value: date, key: "expires_in")
                DispatchQueue.main.async {
                    let defaults = UserDefaults.standard
                    let firstDownload = defaults.string(forKey: "first_download")
                    if firstDownload != nil && firstDownload == "true"
                    {
                        
                    }
                    else{
                        self.firstDownloadFunc()
                    }
                    // self.checkCurrentUser()
                    
                }
                print ("successed \(response.description)")
            }
            catch {
                
            }
        }
    }

    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // MARK: Push notification
  
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Print full message.
        print("REMOTE-LOG \(userInfo)")
        debugPrint(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print full message.
        debugPrint(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
}

//extension AppDelegate : MessagingDelegate {
//    @available(iOS 10.0, *)
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("REMOTE-LOG \(remoteMessage.appData)")
//    }
//
//    func application(received remoteMessage: MessagingRemoteMessage) {
//        print("Im here in notfaction fire base function 11")
//
//        print("notification remoteMessage 2 ")
//    }
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        ConnectToFcm()
//    }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//
//        Messaging.messaging().subscribe(toTopic: "weather") { error in
//            print("Subscribed to weather topic")
//        }
//        print("didReceiveRegistrationToken \(fcmToken)")
//        let dataDict:[String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//    }
//    func ConnectToFcm(){
//        Messaging.messaging().shouldEstablishDirectChannel = true
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instange ID: \(error)")
//            } else if let result = result {
//
//                print("Remote instance ID token: \(result.token)")
//            }
//        }
//    }
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        AppDelegate.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        Messaging.messaging().apnsToken = deviceToken
//        debugPrint("Device token: \(AppDelegate.deviceToken ?? "nil")")
//
//    }
//    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
//
//
//    }
//}


