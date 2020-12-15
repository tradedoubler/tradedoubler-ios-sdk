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

class URLHandler {
    
    private init() {
        session.configuration.timeoutIntervalForRequest = 15
        session.configuration.timeoutIntervalForResource = 15
    }
    
    private var isTrackingEnabled: Bool {
        get {settings.isTrackingEnabled}
    }
    
    private let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: TemporarySessionDelegate.shared, delegateQueue: nil)
    
    static let shared = URLHandler()
    
    let settings = TradeDoublerSDKSettings.shared
    
    func executeURLFromOffline(_ URLString: String) {
        guard let URL = URL(string: URLString) else {
            Logger.TDErrorLog("string pased from save (\(URLString)) is NOT URL string!")
            OfflineDataHandler.shared.requestComplete()
            return
        }
        let task = session.dataTask(with: URL) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                Logger.TDLog(resp.statusCode.description)
                if 200...299 ~= resp.statusCode {
                    OfflineDataHandler.shared.requestComplete(URL)
                }
            }
            if let error = error {
                Logger.TDLog("\(#function) , line: \(#line)\n \(error.localizedDescription)")
                OfflineDataHandler.shared.requestFailed(error, url: URL)
            }
            if let data = data {
                if let toPrint = String(data: data, encoding: .utf8) {
                    Logger.TDLog("server answered: \n \(toPrint)")
                }
            }
        }
        task.resume()
    }
    
    func trackOpenApp() -> Bool {
        var wasUrlCreated = false
        if !isTrackingEnabled {
            Logger.TDLog("Tracking disabled. Open app not tracked.")
            return wasUrlCreated
        }
        guard settings.organizationId != nil else {
            Logger.TDErrorLog("Organization id is null. Configure app before tracking anything. Opening app is not tracked")
            return wasUrlCreated
        }
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Both IDFA & email are not set. Please configure framework. Opening app not tracked")
            return wasUrlCreated
        }
        
        if let emailUrl = buildAppLaunchUrl(isEmail: true) {
            OfflineDataHandler.shared.addRequest(emailUrl)
            wasUrlCreated = true
        }
        if let IDFAUrl = buildAppLaunchUrl(isEmail: false) {
            OfflineDataHandler.shared.addRequest(IDFAUrl)
            wasUrlCreated = true
        }
        return wasUrlCreated
    }
    
    func trackInstall(appInstallEventId: String) -> Bool {
        var wasUrlCreated: Bool = false
        
        if !isTrackingEnabled {
            Logger.TDLog("tracking disabled, returning. Installation not tracked")
            return wasUrlCreated
        }
        
        guard settings.organizationId != nil else {
            Logger.TDErrorLog("Organization id is null. Configure app before tracking anything. Installation is not tracked")
            return wasUrlCreated
        }
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Both IDFA & email are not set. Please configure framework. Installation not tracked")
            return wasUrlCreated
        }
        
        if UserDefaults.standard.bool(forKey: Constants.installedKey) {
            Logger.TDLog("Install track already sent, returning")
            return wasUrlCreated
        }
        let leadNumber = generateRandomString() + "\(Int64(Date().timeIntervalSince1970))"
        
        if let emailUrl = buildTrackInstallUrl(appInstallEventId: appInstallEventId, leadNumber: leadNumber, isEmail: true) {
            OfflineDataHandler.shared.addRequest(emailUrl)
            UserDefaults.standard.set(true, forKey: Constants.installedKey)
            wasUrlCreated = true
        }
        
        if let IDFAUrl = buildTrackInstallUrl(appInstallEventId: appInstallEventId, leadNumber: leadNumber, isEmail: false) {
            OfflineDataHandler.shared.addRequest(IDFAUrl)
            UserDefaults.standard.set(true, forKey: Constants.installedKey)
            wasUrlCreated = true
        }
        return wasUrlCreated
    }
    
    func trackSale(_ eventId: String, _ orderNumber: String, _ orderValue: String, _ currency: String?, _ voucher: String?, _ reportInfo: ReportInfo?) -> Bool {
        var wasUrlCreated = false
        
        if !isTrackingEnabled {
            Logger.TDLog("tracking disabled, returning. Sale not tracked")
            return wasUrlCreated
        }
        
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Missing both email & IDFA. Please configure app")
            return wasUrlCreated
        }
        
        guard let orgId = settings.organizationId, let secretCode = settings.secretCode else {
            var whatIsNull = ""
            if settings.organizationId == nil {
                whatIsNull += "organizationId"
            }
            if settings.secretCode == nil {
                whatIsNull += whatIsNull.count == 0 ? "secretCode" : "and secretCode"
            }
            Logger.TDErrorLog("creating sale tracking step. Aborted because of \(whatIsNull) being null)")
            return wasUrlCreated
        }
        
        let internalVoucher: String?
        if voucher != nil {
            internalVoucher = voucher!.isEmpty ? nil : voucher
        } else {
            internalVoucher = voucher
        }
        
        if let emailUrl = buildTrackSaleUrl(organizationId: orgId, secretCode: secretCode, eventId: eventId, currency: currency, orderValue: orderValue, orderNumber: orderNumber, voucher: internalVoucher, reportInfo: reportInfo, isEmail: true) {
            OfflineDataHandler.shared.addRequest(emailUrl)
            wasUrlCreated = true
        }
        
        if let IDFAUrl = buildTrackSaleUrl(organizationId: orgId, secretCode: secretCode, eventId: eventId, currency: currency, orderValue: orderValue, orderNumber: orderNumber, voucher: internalVoucher, reportInfo: reportInfo, isEmail: false) {
            OfflineDataHandler.shared.addRequest(IDFAUrl)
            wasUrlCreated = true
        }
        return wasUrlCreated
    }
    
    func trackSalePlt(saleEventId: String, orderNumber: String, currency: String?, voucherCode: String?, basketInfo: BasketInfo) -> Bool {
        var wasUrlCreated = false
        if !isTrackingEnabled {
            Logger.TDLog("tracking disabled, returning. Sale PLT not tracked")
            return wasUrlCreated
        }
        
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Missing both email & IDFA. Please configure framework")
            return wasUrlCreated
        }
        
        guard let orgId = settings.organizationId else {
            Logger.TDErrorLog("organizationId is null, please configure framework to track")
            return wasUrlCreated
        }
        if let emailUrl = buildTrackSalePltUrl(organizationId: orgId, saleEventId: saleEventId, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, basketInfo: basketInfo, isEmail: true) {
            OfflineDataHandler.shared.addRequest(emailUrl)
            wasUrlCreated = true
        }
        
        if let IDFAUrl = buildTrackSalePltUrl(organizationId: orgId, saleEventId: saleEventId, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, basketInfo: basketInfo, isEmail: false) {
            OfflineDataHandler.shared.addRequest(IDFAUrl)
            wasUrlCreated = true
        }
        return wasUrlCreated
    }
    
    func trackLead(eventId: String, leadId: String) -> Bool {
        var wasUrlCreated = false
        if !isTrackingEnabled {
            Logger.TDLog("Tracking disabled. Lead not tracked")
            return wasUrlCreated
        }
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Missing both email & IDFA. Lead not tracked. Please configure framework")
            return wasUrlCreated
        }
        
        guard let orgId = settings.organizationId else {
            Logger.TDErrorLog("organizationId is null, please configure framework")
            return wasUrlCreated
        }
        if let emailUrl = buildTrackLeadUrl(organizationId: orgId, eventId: eventId, leadId: leadId, isEmail: true) {
            OfflineDataHandler.shared.addRequest(emailUrl)
            wasUrlCreated = true
        }
        
        if let IDFAUrl = buildTrackLeadUrl(organizationId: orgId, eventId: eventId, leadId: leadId, isEmail: false) {
            OfflineDataHandler.shared.addRequest(IDFAUrl)
            wasUrlCreated = true
        }
        return wasUrlCreated
    }
    
    func countChecksum(secretCode: String, orderNumber: String, orderValue: String) -> String {
        let prefix = "v04"
        let value = Double(orderValue) ?? 0
        let suffix = secretCode + orderNumber + String(format: "%.2f", value)
        return prefix + suffix.md5()
    }
    
    // if has idfa send with idfa if email - send with email. Send both if available
    func ceateAppInstallStep(organizationId: String, eventId: String, email: String? = nil, IDFA: String? = nil, isEmail: Bool) -> URL? {
        let IDFA = settings.IDFA
        let mail = settings.userEmail
        let user: String
        if isEmail{
            if mail == nil {
                return nil
            } else {
                user = mail!
            }
        } else {
            if IDFA == nil {
                return nil
            } else {
                user = email!
            }
        }
        let leadNumber = "\(Int64(Date().timeIntervalSince1970))" + generateRandomString()
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: leadNumber))
        queryItems.append(URLQueryItem(name: "tduid", value: settings.tduid))
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        components.queryItems = queryItems
        return components.url
        
    }
    
    private func generateRandomString(length: Int = 6) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".utf8
        let quantity = UInt32(letters.count)
        var toReturn = ""
        for _ in 0 ..< length {
            let randomNo = Int(arc4random_uniform(quantity))
            let index = letters.index(letters.startIndex, offsetBy: randomNo)
            let character = UnicodeScalar(letters[index])
            toReturn += String(character)
        }
        return toReturn
    }
    
    private func buildTrackInstallUrl(appInstallEventId: String, leadNumber: String, isEmail: Bool) -> URL? {
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Missing both email & IDFA. Wont send tracking install because of wrong configuration ")
            return nil
        }
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email on track install. Will send only with IDFA")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA on track install. Will send only with email")
            return nil
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: settings.organizationId))
        queryItems.append(URLQueryItem(name: "event", value: appInstallEventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: leadNumber))
        queryItems.append(URLQueryItem(name: "tduid", value: settings.tduid))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        queryItems.append(URLQueryItem(name: "extid", value: isEmail ? settings.userEmail : settings.IDFA))
        components.queryItems = queryItems
        return components.url
    }
    
    /// For email login: isEmail must be true & user parameter is set to email address
    /// For IDFA usage: isEmail set to false & user parameter is IDFA string
    /// Developer should default to email if user refuses to use IDFA in settings (or redirect to settings requesting user consent)
    private func buildAppLaunchUrl(isEmail: Bool) -> URL? {
        if settings.userEmail == nil && settings.IDFA == nil {
            Logger.TDErrorLog("Missing both email & IDFA. Wont send tracking launch because of wrong configuration ")
            return nil
        }
        
        guard let organizationId = settings.organizationId else {
            Logger.TDErrorLog("no organization ID on launch, please set organization ID before calling trackOpenApp()")
            return nil
        }
        
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email on tracking launch. Will send only with IDFA")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA on tracking launch. Will send only with email")
            return nil
        }
        let mail = settings.userEmail
        let IDFA = settings.IDFA
        let host = "tbl.tradedoubler.com"
        if mail == nil && isEmail && IDFA == nil {
            Logger.TDLog("no email on launch")
            return nil
        }
        if !isEmail && IDFA == nil {
            Logger.TDLog("no IDFA on launch")
            return nil
        }
        let user = isEmail ? mail : IDFA
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/user"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "o", value: organizationId))
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        queryItems.append(URLQueryItem(name: "tduid", value: settings.tduid))
        queryItems.append(URLQueryItem(name: "verify", value: "true"))
        components.queryItems = queryItems
        return components.url
    }
    
    private func buildTrackLeadUrl(organizationId: String, eventId: String, leadId: String, isEmail: Bool) -> URL? {
        
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email on tracking lead. Will send only with IDFA")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA on tracking lead. Will send only with email")
            return nil
        }
        
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: leadId))
        queryItems.append(URLQueryItem(name: "extid", value: isEmail ? settings.userEmail : settings.IDFA))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        queryItems.append(URLQueryItem(name: "tduid", value: settings.tduid))
        components.queryItems = queryItems
        return components.url!
    }
    
    private func buildTrackSaleUrl(organizationId: String, secretCode: String, eventId: String, currency: String?, orderValue:String, orderNumber: String, voucher: String? = nil, reportInfo: ReportInfo?, isEmail: Bool) -> URL? {
        
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email on tracking sale. Will send only with IDFA")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA on tracking sale. Will send only with email")
            return nil
        }
        
        let user = isEmail ? settings.userEmail : settings.IDFA
        
        let checksum = countChecksum(secretCode: secretCode, orderNumber: orderNumber, orderValue: orderValue)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "orderNumber", value: orderNumber))
        queryItems.append(URLQueryItem(name: "orderValue", value: orderValue))
        queryItems.append(URLQueryItem(name: "checksum", value: checksum))
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        if currency != nil {queryItems.append(URLQueryItem(name: "currency", value: currency))}
        if voucher != nil {queryItems.append(URLQueryItem(name: "voucher", value: voucher))}
        queryItems.append(URLQueryItem(name: "tduid", value: settings.tduid))
        var extendedSet = CharacterSet.urlQueryAllowed
        extendedSet.insert("|")//needed in this query
        if let info = reportInfo?.toEncodedString().addingPercentEncoding(withAllowedCharacters: extendedSet), !info.isEmpty {
            queryItems.append(URLQueryItem(name: "reportInfo", value: info))
        }
        components.queryItems = queryItems
        return components.url
    }
    
    private func buildTrackSalePltUrl(organizationId: String, saleEventId: String, orderNumber: String, currency: String?, voucherCode: String?, basketInfo: BasketInfo, isEmail: Bool) -> URL? {
        
        guard !basketInfo.basketEntries.isEmpty else {
            Logger.TDLog("PLT basket cannot be empty, returning")
            return nil
        }
        
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email on tracking sale. Will send only with IDFA")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA on tracking sale. Will send only with email")
            return nil
        }
        
        if isEmail && settings.userEmail == nil {
            Logger.TDLog("No email, returning")
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            Logger.TDLog("No IDFA, returning")
            return nil
        }
        var checksum: String? = nil
        if let secretCode = settings.secretCode {
            checksum = countChecksum(secretCode: secretCode, orderNumber: orderNumber, orderValue: basketInfo.orderValue)
        }
        var queryParam = "https://tbs.tradedoubler.com/report?o(\(organizationId))"
        queryParam.append("event(\(saleEventId))")
        queryParam.append("ordnum(\(orderNumber))")
        if let currency = currency {
            queryParam.append("curr(\(currency))")
        }
        if let checksum = checksum {
            queryParam.append("chksum(\(checksum))")
        }
        queryParam.append("tduid(\(settings.tduid ?? ""))")
        let user = isEmail ? settings.userEmail! : settings.IDFA!
        queryParam.append("extid(\(user))")
        queryParam.append("exttype(1)")
        if let voucher = voucherCode {
            queryParam.append("voucher(\(voucher))")
        }
        queryParam.append("enc(3)")
        queryParam.append("basket(\(basketInfo.toEncodedString()))")
        if let filtered = queryParam.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryParam = filtered
        }
        let toReturn = URL.init(string: queryParam)
        Logger.TDLog("\(#function) returned \(toReturn.debugDescription)")
        return toReturn
    }
}

class TemporarySessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    private override init() {}
    static let shared = TemporarySessionDelegate()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            Logger.TDLog("\(#function) redirecting to \(url)")
            let components = URLComponents(string: url)
            guard let tduid = components?.queryItems?.filter({ (item) -> Bool in
                item.name.lowercased() == "tduid"
            }).first else {
                if let url = request.url {
                    OfflineDataHandler.shared.performRedirect(url)
                }
                return
            }
            OfflineDataHandler.shared.requestComplete()
            DispatchQueue.main.async {
                TradeDoublerSDKSettings.shared.tduid = tduid.value
            }
        }
    }
    
}
