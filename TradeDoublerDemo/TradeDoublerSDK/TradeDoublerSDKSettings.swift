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

public let tduidKey = "tduid"
let tduidTimestampKey = "tduidTimestamp"
let emailKey = "mail"
let IDFAKey = "idfa"
//public let recoveredKey = "recovered"
let orderNo = "orderNo"
let leadNo = "leadNo"
let organizationIdKey = "organizationIdentifier"
let secretKey = "userSecret"

class TradeDoublerSDKSettings {
    
    var tduid: String? {
        get {
            var savedTimestamp = UserDefaults.standard.double(forKey: tduidTimestampKey)
            if savedTimestamp.isNaN {// reading nil from settings may get you NaN
                savedTimestamp = 0
            }
            if Date().timeIntervalSince1970 - savedTimestamp > secondsTduidIsValid {
                UserDefaults.standard.setValue(nil, forKey: tduidKey)
                UserDefaults.standard.setValue(Double(0), forKey: tduidTimestampKey)
                return nil
            }
            return UserDefaults.standard.string(forKey: tduidKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: tduidKey)
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: tduidTimestampKey)
        }
    }
    
    var secondsTduidIsValid: Double{
        get {
            return 365 * 24 * 60 * 60
        }
    }
    
    var organizationId: String? {
        get {
            return UserDefaults.standard.string(forKey: organizationIdKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: organizationIdKey)
        }
    }
    
    //set "plain" email, will be saved securely. Returns sha or nil on read
    var userEmail: String? {
        get {
            UserDefaults.standard.string(forKey: emailKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: emailKey)
        }
    }
    
    var secretCode: String? {
        get {
            UserDefaults.standard.string(forKey: secretKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: secretKey)
        }
    }
    
    ///set "plain" IDFA, will be saved securely if not null (zeros). Returns sha or nil on read
    var IDFA: String? {
        get {
            if #available(iOS 14.0, *) {
                if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized {
                    return nil
                }
            }
            else if !ASIdentifierManager.shared().isAdvertisingTrackingEnabled{
                return nil
            }
            return UserDefaults.standard.string(forKey: IDFAKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: IDFAKey)
        }
    }
    
    var orderNumber: String { //internal for framework, cannot be set
        get {
            return "\(UserDefaults.standard.integer(forKey: orderNo))"
        }
        
        set {
            var temp = UserDefaults.standard.integer(forKey: orderNo)
            temp = temp + 1
            UserDefaults.standard.setValue(temp, forKey: orderNo)
        }
    }
    
    var leadNumber: String { //internal for framework, cannot be set
        get {
            return "\(UserDefaults.standard.integer(forKey: leadNo))"
        }
        
        set {
            var temp = UserDefaults.standard.integer(forKey: leadNo)
            temp = temp + 1
            UserDefaults.standard.setValue(temp, forKey: leadNo)
        }
    }
    
    private init() {}
    
    static let shared = TradeDoublerSDKSettings()
    
}
