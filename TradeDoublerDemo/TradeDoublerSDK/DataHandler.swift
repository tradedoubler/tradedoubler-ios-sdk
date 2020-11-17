//
//  DataHandler.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 17/11/2020.
//

import Foundation

public let tduidKey = "tduid"
public let recoveredKey = "recovered"

class DataHandler {
    
    var tduid: String? {
        get {
            return UserDefaults.standard.string(forKey: tduidKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: tduidKey)
        }
    }
    
    private init() {}
    
    static let shared = DataHandler()
    
}
