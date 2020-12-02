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
    private let settings = TradeDoublerSDKSettings.shared
    private let offlineManager = OfflineDataHandler.shared
    
    public func simulateTDUIDClick(host: String, path: String, parameters: [String:String]) {
        if let tduid = settings.tduid {
            let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [tduidKey : tduid, recoveredKey: true])
            DispatchQueue.main.async {
                NotificationCenter.default.post(toPost)
            }
        } else {
            simulateFirstClick(host: host, path: path, parameters: parameters)
        }
        
    }
    
    func login(email: String) {
        settings.userEmail = email
        //set email basically
    }
    
    func setTracking(enabled: Bool) {
        urlHandler.isTrackingEnabled = enabled
    }
    
    public func trackSale(eventId: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: ReportInfo?) {
        urlHandler.trackSale(eventId: eventId, currency: currency, orderValue: orderValue, reportInfo: reportInfo)
    }
    
    public func trackLead(eventId: String) {
//        let tduid = DataHandler.shared.tduid!
        urlHandler.trackLead(eventId: eventId)
    }
    
    public func trackOpenApp() {
        urlHandler.trackOpenApp()
    }
    
    public func trackInstall(appInstallEventId: String) {
        urlHandler.trackInstall(appInstallEventId: appInstallEventId)
    }
    
    func simulateFirstClick(host: String, path: String, parameters: [String:String]) {
        urlHandler.getTduid(host: host, path: path, parameters: parameters)//recognize url type, set or read tduid
    }
    
    public func setEmail(_ email: String) {
        settings.userEmail = email
    }
    
    public func logout() {
        settings.userEmail = nil
    }
    
    public func setIDFA(_ IDFA: String) {
        if !IDFA.isNilUUIDString() {
            settings.IDFA = IDFA
        } else {
            settings.IDFA = nil
        }
    }
    
    public func setTDUID(_ TDUID: String) {
        settings.tduid = TDUID
    }
    
    public func organizationId() -> String? {
        return settings.organizationId
    }
    /// email & IDFA are configured in separate methods due to protection level
    public func configure(tduid: String? = nil, organizationId: String? = nil, secretCode: String? = nil, orderNumber: String = "") {
        if tduid != nil {
            settings.tduid = tduid
        }
        if organizationId != nil {
            settings.organizationId = organizationId
        }
        if secretCode != nil {
            settings.secretCode = secretCode
        }
        if !orderNumber.isEmpty {
            settings.orderNumber = orderNumber
        }
    }
}
