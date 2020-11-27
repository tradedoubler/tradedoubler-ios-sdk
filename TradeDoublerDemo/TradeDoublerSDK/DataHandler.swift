//
//  DataHandler.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 17/11/2020.
//

import Foundation

let tduidKey = "tduid"
let emailKey = "mail"
let IDFAKey = "idfa"
public let recoveredKey = "recovered"
let orderNo = "orderNo"

class DataHandler {
    
    var tduid: String? {
        get {
            return UserDefaults.standard.string(forKey: tduidKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: tduidKey)
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
    //set "plain" email, will be saved securely. Returns sha or nil on read
    var email: String? {
        get {
            UserDefaults.standard.string(forKey: emailKey)
        }
        set {
            UserDefaults.standard.setValue(newValue?.sha256(), forKey: emailKey)
        }
    }
    
    var orderNumber: String {
        get {
            let temp = UserDefaults.standard.integer(forKey: orderNo)
            return "\(temp)"
        }
        
        set {
            var temp = UserDefaults.standard.integer(forKey: orderNo)
            temp = temp + 1
            UserDefaults.standard.setValue(temp, forKey: orderNo)
        }
    }
    
    private init() {}
    
    static let shared = DataHandler()
    
}
