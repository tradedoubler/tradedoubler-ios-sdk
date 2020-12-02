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
        // Do any additional setup after loading the view.
    }

    @IBAction func sdkSale(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSale, sender: self)
        return
        tradeDoubler.trackSale(eventId: sdk_sale, currency: nil, orderValue: "\(arc4random_uniform(100000) + 1)", reportInfo: nil)//  randomEvent(organizationId: appDelegate.orgId, user: appDelegate.user, isEmail: appDelegate.isEmail)
    }
    
    @IBAction func sdkSale2(_ sender: Any) {
        performSegue(withIdentifier: segueId.segueToSalePLT, sender: self)
        return
        tradeDoubler.trackSale(eventId: sdk_sale_2, currency: nil, orderValue: "\(arc4random_uniform(100000) + 1)", reportInfo: nil)
    }
    
    @IBAction func sdkLead(_ sender: Any) {
        performSegue(withIdentifier: segueId.SegueToLead, sender: self)
        return
        tradeDoubler.trackLead(eventId: sdk_lead)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case segueId.segueToSale:
            segue.destination.title = "SALE"
        case segueId.segueToSalePLT:
            segue.destination.title = "SALE_PLT"
        case segueId.SegueToLead:
            segue.destination.title = "LEAD"
        default:
            print("UNKNOWN SEGUE \(segue.identifier.debugDescription)")
        }
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
//        TDSDKInterface.shared.firstRequest(host: appDelegate.host, organizationId: appDelegate.organizationId, user: advertisingIdentifier, tduid: appDelegate.tduid, isEmail: false)
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

