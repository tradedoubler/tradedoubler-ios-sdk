//
//  SaleViewController.swift
//  TradeDoublerDemo
//
//  Created by AdamT on 02/12/2020.
//

import UIKit
import TradeDoublerSDK

class SaleViewController: UIViewController {

    var entries = ReportInfo(entries: [])
    let tradeDoubler = TDSDKInterface.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var voucherField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    
    @IBAction func addItem(_ sender: Any) {
        let newEntry = ReportEntry(id: "\(arc4random_uniform(UINT32_MAX))", productName: nameField.text ?? "", price: Double(priceField.text ?? "0") ?? 0, quantity: Int(quantityField.text ?? "0") ?? 0)
        entries.append(newEntry)
        nameField.text = ""
        priceField.text = ""
        quantityField.text = ""
    }
    
    @IBAction func setAndCall(_ sender: Any) {
        tradeDoubler.trackSale(eventId: sdk_sale, currency: currencyField.text, reportInfo: entries)
        dismiss(animated: true, completion: nil)
    }
}
