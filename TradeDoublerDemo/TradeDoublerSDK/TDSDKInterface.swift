//Copyright 2020 Tradedoubler
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import Foundation

public class TDSDKInterface {
    private init() {}
    
    public static let shared = TDSDKInterface()
    private let urlHandler = URLHandler.shared
    private let settings = TradeDoublerSDKSettings.shared
    private let offlineManager = OfflineDataHandler.shared
    
    /**
     User identifier obtained from Tradedoubler® on clicking link for install / launching App
     */
    public var tduid: String? {
        get {
            settings.tduid
        }
        set {
            settings.tduid = newValue
        }
    }
    
    /**
     Users email address (after logging in). Stored as SHA hash string. If nil (not logged in) framework won't generate requests with email
     */
    public var email: String? {
        get {
            settings.userEmail
        }
        set {
            settings.userEmail = newValue
        }
    }
    
    /**
     If set to false only error logs will appear in console
     */
    public var isLoggingEnabled: Bool {
        get {
            settings.isDebug
        }
        set {
            settings.isDebug = newValue
        }
    }
    
    /**
     Framework internal setting. If set to false won't generate tracking requests. If true will comply to system settings (wont use IDFA if tracking limited)
     */
    public var isTrackingEnabled: Bool {
        get {
            settings.isTrackingEnabled
        }
        set {
            settings.isTrackingEnabled = newValue
        }
    }
    
    /**
     Identifier of your organization from Tradedoubler®. Obligatory for all requests
     */
    public var organizationId: String? {
        get {
            settings.organizationId
        }
        set {
            settings.organizationId = newValue
        }
    }
    
    public var secretCode: String? {
        get {
            settings.secretCode
        }
        set {
            settings.secretCode = newValue
        }
    }
    /**
     Convenience method for initializing tduid from obtained URL
     
     - Parameter url: url with default structure that can contain tduid parameter
     
     - Returns: true if tduid was succesfully set, false otherwise
     */
    
    public func handleTduidUrl(url: URL) -> Bool {
        let components = URLComponents(string: url.absoluteString)
        guard let tduid = components?.queryItems?.filter({ (item) -> Bool in
            item.name.lowercased() == "tduid"
        }).first?.value else {return false }
        self.tduid = tduid
        return true
    }
    
    /**
     Method for tracking sale (NOT PLT)
     
     - Parameter saleEventId: event identifier that is affiliated with your organization. Obtained from Tradedoubler®
     - Parameter orderNumber: unique order number
     - Parameter orderValue: value of order. You may pass reportInfo.orderValue if it was set
     - Parameter currency: if not nil, must be ISO-4217 valid code
     - Parameter voucherCode: optional voucher code. Should be affiliated with organization
     - Parameter reportInfo: optional info about basket. If possible, avoid not UTF-8 characters in product names
     
     - Returns: Discardable flag informing if request was created. False if configured to not tracking OR nil IDFA & email in settings
     */
    @discardableResult public func trackSale(saleEventId: String, orderNumber: String, orderValue: String, currency: String?, voucherCode: String?, reportInfo: ReportInfo?) -> Bool {
        urlHandler.trackSale(saleEventId, orderNumber, orderValue, currency, voucherCode, reportInfo)
    }
    
    /**
     Default method for tracking PLT sale
     
     - Parameter orderNumber: unique order number
     - Parameter currency: if not nil, must be ISO-4217 valid code
     - Parameter voucherCode: optional voucher code. Should be affiliated with organization
     - Parameter basketInfo: required info about basket. If possible, avoid not UTF-8 characters in product names
     
     - Returns: Discardable flag informing if request was created. False if configured to not tracking OR nil IDFA & email in settings
     */
    @discardableResult public func trackSalePlt(orderNumber: String, currency: String?, voucherCode: String?, reportInfo: BasketInfo) -> Bool {
        trackSalePlt(saleEventId: Constants.DEFAULT_SALE_EVENT, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, reportInfo: reportInfo)
    }
    
    /**
     Method for tracking PLT sale giving possibility to change eventId (if value is 51 it's recommended to use method without saleEventId parameter)
     
     - Parameter saleEventId: Sale PLT event identifier - if custom is needed. Obtained from Tradedoubler®
     - Parameter orderNumber: unique order number
     - Parameter currency: if not nil, must be ISO-4217 valid code
     - Parameter voucherCode: optional voucher code. Should be affiliated with organization
     - Parameter basketInfo: required info about basket. If possible, avoid not UTF-8 characters in product names
     
     - Returns: Discardable flag informing if request was created. False if configured to not tracking OR nil IDFA & email in settings
     */
    @discardableResult public func trackSalePlt(saleEventId: String, orderNumber: String, currency: String?, voucherCode: String?, reportInfo: BasketInfo) -> Bool {
        urlHandler.trackSalePlt(saleEventId: saleEventId, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, basketInfo: reportInfo)
    }
    /**
     Method for tracking lead
     
     - Parameter leadEventId: lead identifier that is affiliated with your organization, obtained from Tradedoubler®
     - Parameter leadId: unique lead identifier
     
     - Returns: flag informing if request was sent. False if configured to not tracking OR nil IDFA & email in settings
     */
    @discardableResult public func trackLead(leadEventId: String, leadId: String) -> Bool {
        urlHandler.trackLead(eventId: leadEventId, leadId: leadId)
    }
    /**
     Method for tracking app installing. Should be called only once (on first launch)
     
     - Parameter appInstallEventId: your organization's app install event identifier from Tradedoubler®
     
     - Returns: flag informing if request was created. False if configured to not tracking OR nil IDFA & email in settings
     */
    @discardableResult public func trackInstall(appInstallEventId: String) -> Bool {
        urlHandler.trackInstall(appInstallEventId: appInstallEventId)
    }
    /**
     Method for logging user out (removing email from app data)
     
     */
    public func logout() {
        settings.userEmail = nil
    }
    /**
     Method for configuring framework
     
     - Parameter organizationId: identifier of your organization from Tradedoubler®. Obligatory for all requests
     - Parameter secretCode: secret code of your organization from Tradedoubler®. Obligatory for sale requests
     
     - Returns: flag informing if request was created. False if configured to not tracking OR nil IDFA & email in settings
     */
    public func configure(_ organizationId: String?, _ secretCode: String?) {
        
        settings.organizationId = organizationId
        settings.secretCode = secretCode
    }
}
