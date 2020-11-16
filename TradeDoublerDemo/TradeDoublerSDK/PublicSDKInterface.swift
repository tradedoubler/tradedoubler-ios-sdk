//
//  PublicSDKInterface.swift
//  TradeDoublerSDK
//
//  Created by Adam Tucholski on 28/10/2020.
//

import Foundation

public class Tracker {
    private init() {}
    
    public static let shared = Tracker()
    private let logger = InternalLogger.shared
    
    public func track(_ url: URL, tduid: String) {
        logger.urlPassed(url: url, tduid: tduid)//recognize url type, set or read tduid
    }
    
    public func firstRequest(host: String, organizationId: String, user: String, tduid: String, isEmail: Bool) {
        logger.firstRequest(host: host, organizationId: organizationId, user: user, tduid: tduid, isEmail: isEmail)
    }
}
