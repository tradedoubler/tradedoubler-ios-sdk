//
//  DemoViewController.swift
//  TradeDoublerDemo
//
//  Created by Adam Tucholski on 28/10/2020.
//

import UIKit
import AppTrackingTransparency
import AdSupport
import TradeDoublerSDK

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func useIDFA(_ sender: Any) {
        //ask for IDFA right after
        guard let advertisingIdentifier =  UserDefaults.standard.string(forKey: "advertisingIdentifier") else {
            if #available(iOS 14.0, *) {
                requestPermission()
            }
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setIDFA(advertisingIdentifier)
    }
    @available(iOS 14, *)
    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    DispatchQueue.main.async {
                        let advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        UserDefaults.standard.set(advertisingIdentifier, forKey: "advertisingIdentifier")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setIDFA(advertisingIdentifier)
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

