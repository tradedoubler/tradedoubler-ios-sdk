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
    
//    public func randomEvent(organizationId: String, user: String, isEmail: Bool? = nil) {
//        urlHandler.randomEvent(organizationId: organizationId, user: user, isEmail: isEmail)
//    }
    
    public func trackSale(organizationId: String, eventId: String, secretCode: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: String?, user: String, isEmail: Bool) {
        let tduid = DataHandler.shared.tduid!
        urlHandler.trackSale(organizationId: organizationId, eventId: eventId, secretCode: secretCode, currency: currency, orderValue: orderValue, reportInfo: reportInfo, tduid: tduid, user: user, isEmail: isEmail)
    }
    
    public func trackLead(organizationId: String, eventId: String, secretCode: String, timeout: Int, user: String, isEmail: Bool) {
//        let tduid = DataHandler.shared.tduid!
        urlHandler.trackLead(organizationId: organizationId, eventId: eventId, secretCode: secretCode, timeout: timeout, user: user, isEmail: isEmail)
    }
    
    public func trackInstall() {
        
    }
    
    func simulateFirstClick(host: String, path: String, parameters: [String:String]) {
        urlHandler.getTduid(host: host, path: path, parameters: parameters)//recognize url type, set or read tduid
    }
    
    public func configureEmail(_ email: String) {
        DataHandler.shared.email = email
    }
    
    public func logout() {
        DataHandler.shared.email = nil
    }
    
    public func configureIDFA(_ IDFA: String) {
        if !IDFA.isNilUUIDString() {
            DataHandler.shared.IDFA = IDFA
        } else {
            DataHandler.shared.IDFA = nil
        }
    }
    
    public func appLaunch(organizationId: String) {
        urlHandler.appLaunch(organizationId: organizationId)
    }
    
}
