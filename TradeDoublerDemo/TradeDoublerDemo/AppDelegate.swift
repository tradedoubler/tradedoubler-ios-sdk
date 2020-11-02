//
//  AppDelegate.swift
//  TradeDoublerDemo
//
//  Created by Adam Tucholski on 28/10/2020.
//

import UIKit
import TradeDoublerSDK
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let options = launchOptions,
              let url = options[UIApplication.LaunchOptionsKey(rawValue: "url")] as? URL, let tduid = options[UIApplication.LaunchOptionsKey(rawValue: "tduid")] as? String else {
            passToSDK(url: URL.init(string: "www.google.pl")!, tduid: "some tduid (stub, none obtained)")
            return true
        }
        passToSDK(url: url, tduid: tduid)
            return true
        }

    // MARK: UISceneSession Lifecycle
        @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
//Try to detect TDUID on URL opening header
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("opening URL: \(url.absoluteString)")
        
        for key in options.keys {
            print("value for \(key) is \(String(describing: options[key]))")
            if key.rawValue == "tduid" {
                passToSDK(url: url, tduid: options[key] as! String)
                return true
            }
        }
        print("failure when opening url \(url)")
        return false
    }

    func passToSDK(url: URL, tduid: String) {
        let tracker = Tracker()
        tracker.track(url, tduid: tduid)
    }
}
