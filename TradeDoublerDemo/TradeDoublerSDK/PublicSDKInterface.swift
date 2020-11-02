//
//  PublicSDKInterface.swift
//  TradeDoublerSDK
//
//  Created by Adam Tucholski on 28/10/2020.
//

import Foundation

public class Tracker {
    public init() {}
    
    public func track(_ url: URL, tduid: String) {
        let logger = InternalLogger()
        logger.urlPassed(url: url, tduid: tduid)//recognize url type, set or read tduid
    }
}
