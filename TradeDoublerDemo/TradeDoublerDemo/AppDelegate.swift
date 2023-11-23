//Copyright 2020 Tradedoubler
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import UIKit
import TradeDoublerSDK
//defined sdk events
let sdk_sale = "403759"
let sdk_app_install = "403761"
let sdk_sale_2 = "403763"
let sdk_lead = "403765"
let sdk_plt_default = "51"
let sdk_group_1 = "3408"
let sdk_group_2 = "3168"

//UserDefaults Key
let defaultCurrencyKey = "defaultCurrency"
let organizationIdKey = "organizationIdentifier"
let secretKey = "userSecret"
let trackingKey = "isTrackingEnabled"
let debugKey = "isDebugEnabled"

//Notifications keys
let tduidFound = Notification.Name(rawValue: "TDUIDFound")

//defined segue IDs to avoid typos
struct segueId {
    static let segueToSale = "SegueToSale"
    static let segueToSalePLT = "SegueToSalePLT"
    static let segueToLead = "SegueToLead"
}

func keyWindow() -> UIWindow? {
    if #available(iOS 15.0, *) {
        return UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    } else {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}

func present(alert: UIAlertController) {
    keyWindow()?.rootViewController?.present(alert, animated: true)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let tradeDoubler = TDSDKInterface.shared
    
    @objc private func gotTduid(_ notification: Notification) {
        defer {
            reconfigureRootView()
        }
        guard let tduid = notification.userInfo?[Constants.tduidKey] as? String else {return}
        
        tradeDoubler.tduid = tduid
    }
    
    func reconfigureRootView() {
        if let root = keyWindow()?.rootViewController as? DemoViewController {
            root.setOutlets()
        }
    }
    
    func configureFramework() {
        let defaults = UserDefaults.standard
        tradeDoubler.email = "test24588444@tradedoubler.com"
        TDSDKInterface.shared.configure(defaults.string(forKey: organizationIdKey), defaults.string(forKey: secretKey))
        tradeDoubler.isTrackingEnabled = defaults.bool(forKey: trackingKey)
        tradeDoubler.isLoggingEnabled = defaults.bool(forKey: debugKey)
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        configureFramework()
    }
    
    func presentAlert(title: String, message: String? = nil, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {_ in
                alert.dismiss(animated: true, completion: {
                    self.reconfigureRootView()
                })
            }))
        }
        
        present(alert: alert)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotTduid(_:)), name: tduidFound, object: nil)
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: secretKey) == nil {
            defaults.setValue("945630", forKey: organizationIdKey)
            defaults.setValue("123456789", forKey: secretKey)
            defaults.setValue(true, forKey: trackingKey)
            defaults.setValue(true, forKey: debugKey)
            defaults.setValue("EUR", forKey: defaultCurrencyKey)
        }
//        https://clk.tradedoubler.com/click?p(310409)a(982247)g(0) - click simulation
        let parameters = [
            "p" : "310409",
            "a" : "982247",
            "g" : "0",
            "f" : "0"// f is from first response (head meta tag)
        ]
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            handleOpeningUrl(url: url, onLaunch: true)
        }
        configureFramework()
        simulateTduidUrl("clk.tradedoubler.com", "/click", parameters)
        tradeDoubler.trackOpenApp()
        
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
        handleOpeningUrl(url: url, onLaunch: false)
        return true
    }
    
    func handleOpeningUrl(url: URL, onLaunch: Bool) {
        
        if tradeDoubler.handleTduidUrl(url: url) {
            DispatchQueue.main.asyncAfter(deadline: .now() + (onLaunch ? 1 : 0)) {
                let alert = UIAlertController.init(title: "opened URL", message: "\(url.absoluteString), tudid: \(TDSDKInterface.shared.tduid!)", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                present(alert: alert)
            }
        }
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("update activity \(userActivity)")
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print("will continue activity \(userActivity.debugDescription)")
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("failed activity \(userActivity.debugDescription) error: \(error.localizedDescription)")
    }
    
    func simulateTduidUrl(_ host: String, _ path: String, _ parameters: [String:String]) {
        if let tduid = tradeDoubler.tduid {
            let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [Constants.tduidKey : tduid])
            DispatchQueue.main.async {
                NotificationCenter.default.post(toPost)
            }
        } else {
            getTduid(host, path, parameters)
        }
        
    }
    
    func getTduid(_ host: String, _ path: String, _ parameters: [String : String]) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        var queryItems = [URLQueryItem]()
        for key in parameters.keys {
            queryItems.append(URLQueryItem(name: key, value: parameters[key]))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                if !(200...299 ~= resp.statusCode) {
                    print("getting TDUID response code: \(resp.statusCode)")
                    
                } else if let redirUrl = resp.url {
                    let components = URLComponents(url: redirUrl, resolvingAgainstBaseURL: false)
                    guard let tduid = components?.queryItems?.filter({ (item) -> Bool in
                        item.name.lowercased() == "tduid"
                    }).first else {
                        return
                    }
                    let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [Constants.tduidKey : tduid.value!])
                    DispatchQueue.main.async {
                        self.tradeDoubler.tduid = tduid.value
                        NotificationCenter.default.post(toPost)
                    }
                }
            }
            if let error = error {
                print("\(#function) , line: \(#line)\n \(error.localizedDescription)")
                let toPost = Notification.init(name: tduidFound, object: nil, userInfo: nil)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(toPost)
                }
            }
        }
        task.resume()
    }
}

extension AppDelegate: URLSessionDelegate, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            let components = URLComponents(string: url)
            guard let tduid = components?.queryItems?.filter({ (item) -> Bool in
                item.name.lowercased() == "tduid"
            }).first else {
                completionHandler(request)
                return
            }
            let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [Constants.tduidKey : tduid.value!])
            DispatchQueue.main.async {
                self.tradeDoubler.tduid = tduid.value
                NotificationCenter.default.post(toPost)
            }
            completionHandler(request)
        }
    }
    
}
