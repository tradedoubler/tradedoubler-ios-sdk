//
//  DataHandler.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 17/11/2020.
//

import Foundation

let tduidKey = "tduid"
let tduidTimestampKey = "tduidTimestamp"
let emailKey = "mail"
let IDFAKey = "idfa"
public let recoveredKey = "recovered"
let orderNo = "orderNo"
let organizationIdKey = "organizationIdentifier"
let secretKey = "userSecret"

class TradeDoublerSDKSettings {
    
    var tduid: String? {
        get {
            if Date().timeIntervalSince1970 - UserDefaults.standard.double(forKey: tduidTimestampKey) > secondsTduidIsValid {
                UserDefaults.standard.setValue(nil, forKey: tduidKey)
                UserDefaults.standard.setValue(nil, forKey: tduidTimestampKey)
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
            UserDefaults.standard.string(forKey: IDFAKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: IDFAKey)
        }
    }
    
    var orderNumber: String {
        get {
            return "\(UserDefaults.standard.integer(forKey: orderNo))"
        }
        
        set {
            var temp = UserDefaults.standard.integer(forKey: orderNo)
            temp = temp + 1
            UserDefaults.standard.setValue(temp, forKey: orderNo)
        }
    }
    
    private init() {}
    
    static let shared = TradeDoublerSDKSettings()
    
}