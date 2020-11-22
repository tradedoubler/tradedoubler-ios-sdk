//
//  DataHandler.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 17/11/2020.
//

import Foundation

public let tduidKey = "tduid"
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
