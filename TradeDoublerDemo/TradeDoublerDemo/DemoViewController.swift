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

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tradeDoubler = TDSDKInterface.shared
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sdkSale(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSale, sender: self)
    }
    
    @IBAction func sdkSale2(_ sender: Any) {
        tradeDoubler.trackSale(eventId: sdk_sale_2, currency: nil, reportInfo: nil)
    }
    
    @IBAction func sdkSalePlt(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSalePLT, sender: self)
    }
    @IBAction func sdkLead(_ sender: Any) {
        tradeDoubler.trackLead(eventId: sdk_lead)
    }
    
    @IBAction func useIDFA(_ sender: Any) {
        //ask for IDFA right after
        guard let advertisingIdentifier =  UserDefaults.standard.string(forKey: "advertisingIdentifier") else {
            if #available(iOS 14.0, *) {
                requestPermission()
            }
            return
        }
        TDSDKInterface.shared.setIDFA(advertisingIdentifier)
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
                        self?.tradeDoubler.setIDFA(advertisingIdentifier)
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

