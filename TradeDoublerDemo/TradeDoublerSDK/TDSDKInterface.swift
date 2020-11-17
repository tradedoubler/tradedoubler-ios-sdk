//
//  TDSDKInterface.swift
//  TradeDoublerSDK
//
//  Created by Adam Tucholski on 28/10/2020.
//

import Foundation

public class TDSDKInterface {
    private init() {}
    
    public static let shared = TDSDKInterface()
    private let urlHandler = URLHandler.shared
    
    public func recoverTDUID(host: String, path: String, parameters: [String:String]) {
        if let tduid = DataHandler.shared.tduid {
            let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [tduidKey : tduid, recoveredKey: true])
            DispatchQueue.main.async {
                NotificationCenter.default.post(toPost)
            }
        } else {
            simulateFirstClick(host: host, path: path, parameters: parameters)
        }
        
    }
    
    func login(isEmail: Bool) {
        
    }
    
    public func randomEvent(organizationId: String, user: String, isEmail: Bool? = nil) {
        urlHandler.randomEvent(organizationId: organizationId, user: user, isEmail: isEmail)
    }
    
    func simulateFirstClick(host: String, path: String, parameters: [String:String]) {
        urlHandler.getTduid(host: host, path: path, parameters: parameters)//recognize url type, set or read tduid
    }
    
    public func firstRequest(host: String, organizationId: String, user: String, tduid: String, isEmail: Bool) {
        urlHandler.firstRequest(host: host, organizationId: organizationId, user: user, tduid: tduid, isEmail: isEmail)
    }
    
}
