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
import AppTrackingTransparency
import AdSupport
import TradeDoublerSDK

class DemoViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tradeDoubler = TDSDKInterface.shared
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sdkSale(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSale, sender: self)
    }
    
    @IBAction func sdkSale2(_ sender: Any) {
        tradeDoubler.trackSale(eventId: sdk_sale_2, currency: nil, voucher: nil, reportInfo: nil)
    }
    
    @IBAction func sdkSalePlt(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSalePLT, sender: self)
    }
    @IBAction func sdkLead(_ sender: Any) {
        tradeDoubler.trackLead(eventId: sdk_lead)
    }
    
    @IBAction func useIDFA(_ sender: Any) {
        //ask for IDFA right after
        if UserDefaults.standard.string(forKey: "advertisingIdentifier") == nil {
            if #available(iOS 14.0, *) {
                requestPermission()
            }
            return
        }
    }
    
    @IBAction func simulateAppInstall(_ sender: Any) {
        tradeDoubler.trackInstall(appInstallEventId: sdk_app_install)
    }
    
    
    @available(iOS 14, *)
    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    DispatchQueue.main.async { [weak self] in
                        let advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        self?.tradeDoubler.IDFA = advertisingIdentifier
                    }
                
                    // Now that we are authorized we can get the IDFA
//                print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                   // Tracking authorization dialog was
                   // shown and permission is denied
                     print("Denied")
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        print("Not Determined")
                case .restricted:
                        print("Restricted")
                @unknown default:
                        print("Unknown")
                }
            }
        }
    
}

