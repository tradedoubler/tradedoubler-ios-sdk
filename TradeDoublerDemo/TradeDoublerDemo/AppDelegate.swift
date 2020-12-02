//
//  AppDelegate.swift
//  TradeDoublerDemo
//
//  Created by Adam Tucholski on 28/10/2020.
//

import UIKit
import TradeDoublerSDK
//defined sdk events
let sdk_sale = "403759"
let sdk_app_install = "403761"
let sdk_sale_2 = "403763"
let sdk_lead = "403765"

//defined segue IDs to avoid typos
struct segueId {
    static let segueToSale = "SegueToSale"
    static let segueToSalePLT = "SegueToSalePLT"
    static let SegueToLead = "SegueToLead"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    //TODO:remove comment below when everything works
    /*https://tbs.tradedoubler.com/user?o=$organization&extid=$extid&exttype=1&tduid=$tduid&verify=true
*/
//    var window: UIWindow?
    let tradeDoubler = TDSDKInterface.shared
    
    @objc private func gotTduid(_ notification: Notification) {
        
        let title: String
        guard  let recovered = notification.userInfo?[recoveredKey] as? Bool else {
            presentAlert(title: "receiving TDUID failed")
            return
        }
        
        if recovered  {
            title = "recovered TDUID"
        } else {
            title = "received TDUID"
            if let tduid = notification.userInfo?["tduid"] as? String {
                TDSDKInterface.shared.setTDUID(tduid)
            }
        }
        
        presentAlert(title: title, message: notification.userInfo?["tduid"] as? String)
    }
    
    func configureFramework() {
        tradeDoubler.setEmail("adam.tucholski@britenet.com.pl")
        tradeDoubler.configure(organizationId: "945630", secretCode: "123456789")
    }
    
    func presentAlert(title: String, message: String? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        let window = UIApplication.shared.keyWindow

        window?.rootViewController?.present(alert, animated: true)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotTduid(_:)), name: tduidFound, object: nil)
        
//        https://clk.tradedoubler.com/click?p(310409)a(982247)g(0) - click simulation
        let parameters = [
            "p" : "310409",
            "a" : "982247",
            "g" : "0",
            "f" : "0"// f is from first response (head meta tag)
        ]
        
        configureFramework()
        TDSDKInterface.shared.simulateTDUIDClick(host: "clk.tradedoubler.com", path: "/click", parameters: parameters)
        
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
        let components = URLComponents(string: url.absoluteString)
        if let tduid = components?.queryItems?.filter({ (item) -> Bool in
            item.name.lowercased() == "tduid"
        }).first?.value {
            tradeDoubler.setTDUID(tduid)
        }
        return false
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("update activity \(userActivity)")
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print("will continue activity \(userActivity.debugDescription)")
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("failedactivity \(userActivity.debugDescription) error: \(error.localizedDescription)")
    }
    
    func setIDFA(_ iDFAString: String) {
        TDSDKInterface.shared.setIDFA(iDFAString)
    }
    
}
