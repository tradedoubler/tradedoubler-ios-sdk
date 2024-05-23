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

import Foundation
import AppTrackingTransparency
import AdSupport

class TradeDoublerSDKSettings {
    
    var tduid: String? {
        get {
            var savedTimestamp = UserDefaults.standard.double(forKey: Constants.tduidTimestampKey)
            if savedTimestamp.isNaN {// reading nil from settings may get you NaN
                savedTimestamp = 0
            }
            if Date().timeIntervalSince1970 - savedTimestamp > secondsTduidIsValid {
                UserDefaults.standard.setValue(nil, forKey: Constants.tduidKey)
                UserDefaults.standard.setValue(Double(0), forKey: Constants.tduidTimestampKey)
                return nil
            }
            return UserDefaults.standard.string(forKey: Constants.tduidKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.tduidKey)
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Constants.tduidTimestampKey)
        }
    }
    
    var secondsTduidIsValid: Double{
        get {
            return 365 * 24 * 60 * 60
        }
    }
    
    var isDebug: Bool {
        get {
            if UserDefaults.standard.value(forKey: Constants.debugKey) != nil {
                return UserDefaults.standard.bool(forKey: Constants.debugKey)}
            return false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.debugKey)
        }
    }

    var isTrackingEnabled: Bool {
        get {
            if UserDefaults.standard.value(forKey: Constants.trackingKey) != nil {
                return UserDefaults.standard.bool(forKey: Constants.trackingKey)}
            return true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.trackingKey)
        }
    }
    
    var organizationId: String? = nil
    
    //set "plain" email, will be saved securely. Returns sha or nil on read
    var userEmail: String? {
        get {
            UserDefaults.standard.string(forKey: Constants.emailKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: Constants.emailKey)
        }
    }
    
    /// iOS SDK specific value: 22
    var ttid: String {
        return "22"
    }
    
    var secretCode: String? = nil
    
    private init() {}
    
    static let shared = TradeDoublerSDKSettings()
    
}
