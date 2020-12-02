//
//  SalePLTViewController.swift
//  TradeDoublerDemo
//
//  Created by AdamT on 02/12/2020.
//

import UIKit
import TradeDoublerSDK

class SalePLTViewController: UIViewController {

    let tradeDoubler = TDSDKInterface.shared
    var entries = BasketInfo(entries: [])
    
    @IBOutlet weak var groupField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var voucherField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func addItem(_ sender: Any) {
        
        var groupTxt = groupField.text
        if groupTxt != nil {
            if groupTxt!.isEmpty {
                groupTxt = sdk_group_2
            }
        } else {
            groupTxt = sdk_group_2
        }
        let newEntry = BasketEntry.init(group: groupTxt!, id: "\(arc4random_uniform(UINT32_MAX))", productName: nameField.text ?? "", price: Double(priceField.text ?? "0") ?? 0, quantity: Int(quantityField.text ?? "0") ?? 0)
        entries.append(newEntry)
        nameField.text = ""
        priceField.text = ""
        quantityField.text = ""
    }
    
    @IBAction func setAndCall(_ sender: Any) {
        tradeDoubler.trackSalePlt(saleEventId: sdk_plt_default, currency: currencyField.text, voucherCode: voucherField.text, basketInfo: entries)
        dismiss(animated: true, completion: nil)
    }

}
