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
    
    @IBOutlet weak var idfaLabel: UILabel!
    @IBOutlet weak var idfaButton: UIButton!
    @IBOutlet weak var tduidLabel: UILabel!
    @IBOutlet weak var loggingSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!

    @IBAction func showSettings(_ sender: Any) {
        UIApplication.shared.open(URL(string:  UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    @IBAction func switchLogging(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: debugKey)
        tradeDoubler.isLoggingEnabled = sender.isOn
    }
    
    @IBAction func switchTracking(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: trackingKey)
        tradeDoubler.isTrackingEnabled = sender.isOn
    }
    
    @IBAction func simulateOpen(_ sender: Any) {
        tradeDoubler.trackOpenApp()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setOutlets), name: UIApplication.willEnterForegroundNotification, object: nil)
        setOutlets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOutlets()
    }

    @objc func setOutlets() {
        UserDefaults.standard.bool(forKey: debugKey)
        
        if #available(iOS 14.0, *) {
            idfaButton.isEnabled = true
        } else {
            idfaButton.isEnabled = false
        }
        emailField.clearButtonMode = .unlessEditing
        trackingSwitch.isOn = UserDefaults.standard.bool(forKey: trackingKey)
        tradeDoubler.isTrackingEnabled = trackingSwitch.isOn
        loggingSwitch.isOn = UserDefaults.standard.bool(forKey: debugKey)
        tradeDoubler.isLoggingEnabled = loggingSwitch.isOn
        idfaLabel.text = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        emailField.text = tradeDoubler.email
        if idfaLabel.text?.isEmpty != false {//is empty or nil
            idfaLabel.text = "(null)"
        } else if idfaLabel.text == "00000000-0000-0000-0000-000000000000" {
            idfaLabel.text = "(null)"
        }
        tduidLabel.text = tradeDoubler.tduid ?? "(null)"
        scrollView.layoutSubviews()
    }
    
    @IBAction func sdkSale(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSale, sender: self)
    }
    
    @IBAction func sdkSale2(_ sender: Any) {
        tradeDoubler.trackSale(saleEventId: sdk_sale_2, orderNumber: "\(arc4random_uniform(UINT32_MAX))", orderValue: "\(arc4random_uniform(10000) + 1)", currency: nil, voucherCode: nil, reportInfo: nil)
    }
    
    @IBAction func sdkSalePlt(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSalePLT, sender: self)
    }
    
    @IBAction func sdkLead(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToLead, sender: self)
    }
    
    @IBAction func useIDFA(_ sender: Any) {
        
        if UserDefaults.standard.string(forKey: "advertisingIdentifier") == nil {
            if #available(iOS 14.0, *) {
                let array: [ATTrackingManager.AuthorizationStatus] = [.notDetermined, .authorized]
                if !array.contains(ATTrackingManager.trackingAuthorizationStatus) {
                    let alert = UIAlertController.init(title: "Using IDFA not allowed", message: "Please go to settings nad allow tracking if you want to use IDFA" , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    present(alert, animated: true, completion: nil)
                } else if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                requestPermission()
                }
            } else {
                if tradeDoubler.isLoggingEnabled {
                    print("On iOS before version 14.0 you don't need authorization to use IDFA, but usage can be limited. Currently \(ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? "not limited" : "limited")")
                }
            }
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
                    DispatchQueue.main.async { [weak self] in
                        let advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        self?.tradeDoubler.IDFA = advertisingIdentifier
                        print("Authorized, IDFA = \(advertisingIdentifier)")
                        self?.setOutlets()
                    }
                
                    // Now that we are authorized we can get the IDFA
//                print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                   // Tracking authorization dialog was
                   // shown and permission is denied
                     print("Denied")
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

extension DemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.trimmedTextOrEmpty()
        if text != tradeDoubler.email, textField == emailField {
            tradeDoubler.email = emailField.text
            setOutlets()
        }
    }
}

extension UITextField {
    func trimmedTextOrEmpty() -> String {
        guard let text = text else {return ""}
        return text.trimmingCharacters(in: .whitespaces)
    }
}
