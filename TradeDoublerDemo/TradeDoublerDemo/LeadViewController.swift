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

class LeadViewController: UIViewController {
    
    let tradedoubler = TDSDKInterface.shared
    @IBOutlet weak var leadIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlets()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOutlets()
    }
    
    func setOutlets() {
        leadIdField.placeholder = "Lead id"
    }
    

    @IBAction func setAndCall(_ sender: Any) {
        let leadId = leadIdField.trimmedTextOrEmpty()
        if leadId.isEmpty {
            leadIdField.text = "empty"
            return
        }
        
        tradedoubler.trackLead(leadEventId: sdk_lead, leadId: leadId)
        dismiss(animated: true, completion: nil)
    }

}

extension LeadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
