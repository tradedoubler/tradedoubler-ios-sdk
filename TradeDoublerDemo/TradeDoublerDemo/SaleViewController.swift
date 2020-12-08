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

class SaleViewController: UIViewController {

    var entries = ReportInfo(entries: [])
    let tradeDoubler = TDSDKInterface.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyField.placeholder = "ISO-4217 code"
        voucherField.placeholder = "voucher code"
        nameField.placeholder = "name"
        priceField.placeholder = "price"
        quantityField.placeholder = "quantity"
    }
    
    func setOutlets() {
        currencyField.text = UserDefaults.standard.string(forKey: defaultCurrencyKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setOutlets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOutlets()
    }
    
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var voucherField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    
    @IBAction func addItem(_ sender: Any) {
        
        let name = nameField.trimmedTextOrEmpty()
        guard let price = Double(priceField.trimmedTextOrEmpty()), price > 0, let quantity = Int(quantityField.trimmedTextOrEmpty()), quantity > 0, !name.isEmpty else {
            if priceField.trimmedTextOrEmpty().isEmpty {
                priceField.text = "0.01"
            }
            if quantityField.trimmedTextOrEmpty().isEmpty {
                quantityField.text = "1"
            }
            if name.isEmpty {
                nameField.text = "empty"
            }
            return
        }
        
        let newEntry = ReportEntry(id: "\(arc4random_uniform(UINT32_MAX))", productName: name, price: price, quantity: quantity)
        entries.append(newEntry)
        if tradeDoubler.isLoggingEnabled {
            print("Added \(newEntry.description)")
        }
        nameField.text = ""
        priceField.text = ""
        quantityField.text = ""
    }
    
    @IBAction func setAndCall(_ sender: Any) {
        let value = entries.reportEntries.isEmpty ? "\(arc4random_uniform(10000) + 1)" : "\(entries.orderValue)"
        _ = tradeDoubler.trackSale(saleEventId: sdk_sale, orderNumber: "\("\(arc4random_uniform(UINT32_MAX))")", orderValue: value, currency: currencyField.text, voucherCode: nil, reportInfo: entries.isEmpty() ? nil : entries)
        dismiss(animated: true, completion: nil)
    }
}
