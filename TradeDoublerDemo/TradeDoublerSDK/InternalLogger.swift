//
//  Logger.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 18/11/2020.
//

import Foundation

class Logger {
    public static var isDebug = true
    
    public static func setDebug(_ flag: Bool) {
        isDebug = flag
    }
    
    public static func TDLOG(_ string: String) {
        if isDebug {
            print(string)
        }
    }
}
