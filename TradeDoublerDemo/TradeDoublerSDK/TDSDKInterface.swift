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
    
    func login(email: String) {
        settings.userEmail = email
    }
    
    func setTracking(enabled: Bool) {
        urlHandler.isTrackingEnabled = enabled
    }
    ///currency must be ISO-4217 valid code
    public func trackSale(eventId: String, currency: String?, voucher: String? = nil, reportInfo: ReportInfo?) {
        urlHandler.trackSale(eventId: eventId, currency: currency, reportInfo: reportInfo)
    }
    
    public func trackSalePlt(currency: String?, voucherCode: String?, basketInfo: BasketInfo) {
        trackSalePlt(saleEventId: Constants.DEFAULT_SALE_EVENT,  currency: currency, voucherCode: voucherCode, basketInfo: basketInfo)
    }
    
    public func trackSalePlt(saleEventId: String = Constants.DEFAULT_SALE_EVENT, currency: String?, voucherCode: String?, basketInfo: BasketInfo) {
        urlHandler.trackSalePlt(saleEventId: saleEventId,  currency: currency, voucherCode: voucherCode, basketInfo: basketInfo)
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
    
    public var tduid: String? {
        get {
            return settings.tduid
        }
        set {
            settings.tduid = newValue
        }
    }
    
    public func organizationId() -> String? {
        return settings.organizationId
    }
    /// email & IDFA are configured in separate methods due to protection level
    public func configure(organizationId: String? = nil, secretCode: String? = nil) {
        if organizationId != nil {
            settings.organizationId = organizationId
        }
        if secretCode != nil {
            settings.secretCode = secretCode
        }
    }
}
