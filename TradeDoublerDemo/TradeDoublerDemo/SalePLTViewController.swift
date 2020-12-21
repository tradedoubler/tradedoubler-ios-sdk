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
        groupField.placeholder = "products group"
        currencyField.placeholder = "ISO-4217 code"
        voucherField.placeholder = "voucher code"
        nameField.placeholder = "name"
        priceField.placeholder = "price"
        quantityField.placeholder = "quantity"
        groupField.text = sdk_group_1
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
        
        if groupField.trimmedTextOrEmpty().isEmpty {
            groupField.text = sdk_group_2
        }
        
        let newEntry = BasketEntry(group: groupField.trimmedTextOrEmpty(), id: "\(arc4random_uniform(UINT32_MAX))", productName: name, price: price, quantity: quantity)
        if tradeDoubler.isLoggingEnabled {
            print("Added \(newEntry.description)")
        }
        entries.append(newEntry)
        nameField.text = ""
        priceField.text = ""
        quantityField.text = ""
    }
    
    @IBAction func setAndCall(_ sender: Any) {
        if entries.isEmpty() {
            if tradeDoubler.isLoggingEnabled {
                print("can't send empty basket on sale PLT!")
            }
            return
        }
        tradeDoubler.trackSalePlt(saleEventId: sdk_plt_default, orderNumber: "\(arc4random_uniform(UINT32_MAX))", currency: currencyField.text, voucherCode: voucherField.text, reportInfo: entries)
        dismiss(animated: true, completion: nil)
    }

}

extension SalePLTViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
