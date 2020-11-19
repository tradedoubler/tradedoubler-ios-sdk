//
//  Logger.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 18/11/2020.
//

import Foundation

class Logger {
    
    static func isDebug() -> Bool{
        #if DEBUG//only in development
        return true
        #else
        return false
        #endif
    }
    
    
    public static func TDLOG(_ string: String) {
        if isDebug() {
            print(string)
        }
    }
}
