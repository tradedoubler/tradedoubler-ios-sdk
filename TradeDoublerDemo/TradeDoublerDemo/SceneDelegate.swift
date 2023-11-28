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

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let tradeDoubler = TDSDKInterface.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        configureFramework()
        handleOpeningUrl(URLContexts: connectionOptions.urlContexts, onLaunch: true)
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        configureFramework()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleOpeningUrl(URLContexts: URLContexts, onLaunch: false)
    }
    
    func configureFramework() {
        let defaults = UserDefaults.standard
        tradeDoubler.email = "test24588444@tradedoubler.com"
        tradeDoubler.configure(defaults.string(forKey: organizationIdKey), defaults.string(forKey: secretKey))
        tradeDoubler.isTrackingEnabled = defaults.bool(forKey: trackingKey)
        tradeDoubler.isLoggingEnabled = defaults.bool(forKey: debugKey)
    }
    
    func handleOpeningUrl(URLContexts: Set<UIOpenURLContext>, onLaunch: Bool) {
        for context in URLContexts {
            let url = context.url
            if tradeDoubler.handleTduidUrl(url: url) {
                DispatchQueue.main.asyncAfter(deadline: .now() + (onLaunch ? 1 : 0)) {
                    let alert = UIAlertController.init(title: "opened URL", message: "\(url.absoluteString), tudid: \(TDSDKInterface.shared.tduid!)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                    present(alert: alert)
                }
                break
            }
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("continue with scene, activity: \(userActivity.debugDescription)")
    }

    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("failed activity: \(userActivity.debugDescription)")
    }
}

