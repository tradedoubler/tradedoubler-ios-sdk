//
//  URLHandler.swift
//  TradeDoublerSDK
//
//  Created by Adam Tucholski on 28/10/2020.
//

import Foundation

class URLHandler {
    
    private init() {}
    
    private let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: TemporarySessionDelegate.shared, delegateQueue: nil)
    
    static let shared = URLHandler()
    
    let settings = TradeDoublerSDKSettings.shared
    
    var isTrackingEnabled = true
    
    func getTduid(host: String, path: String, parameters: [String : String]) {
        //https://clk.tradedoubler.com/click?p(310409)a(982247)g(0)
        //https://clk.tradedoubler.com/click?a=982247&p=310409&g=0&f=0
        Logger.TDLOG("at start we have orderNo = " + "\(TradeDoublerSDKSettings.shared.orderNumber)")
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        var queryItems = [URLQueryItem]()
        for key in parameters.keys {
            queryItems.append(URLQueryItem(name: key, value: parameters[key]))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        let url = components.url!
        Logger.TDLOG("\(url) in line \(#line) of \(#file)")
        let task = session.dataTask(with: url) { (data, response, error) in
            /*if let redirUrl = response?.url {
                let components = URLComponents.init(url: redirUrl, resolvingAgainstBaseURL: false)
                let item = queryItems.filter { (item) -> Bool in
                    item.name ==
                }
            }*/
            if let redir = response?.url {
                Logger.TDLOG("gotta \(redir)")
            }
            if let resp = response as? HTTPURLResponse {
                Logger.TDLOG(resp.statusCode.description)
            }
            if let error = error {
                Logger.TDLOG("\(#function) , line: \(#line)\n \(error.localizedDescription)")
            }
            if let data = data {
                guard let toPrint = String(data: data, encoding: .utf8) else {
                    Logger.TDLOG("file \(#file) line: \(#line) \nNO STRING")
                    return
                }
                Logger.TDLOG("server answered: \n \(toPrint)")
                Logger.TDLOG(toPrint)
            }
        }
        task.resume()
//        Logger.TDLOG("Your tduid to be securely saved & used later is: \(tduid)")
    }
    
    //get email & idfa from storage
    func trackOpenApp() {
        if !isTrackingEnabled {
            return
        }
        
        if let emailUrl = buildAppLaunchUrl(isEmail: true) {
            Logger.TDLOG("file \(#file) line \(#line) url: \(emailUrl)")
            let emailTask = session.dataTask(with: emailUrl) { (data, response, error) in
                if let resp = response as? HTTPURLResponse {
                    Logger.TDLOG(resp.statusCode.description)
                }
                if let error = error {
                    Logger.TDLOG("\(#function) , line: \(#line)\n \(error.localizedDescription)")
                }
                if let data = data {
                    guard let toPrint = String(data: data, encoding: .utf8) else {
                        Logger.TDLOG("file \(#file) line: \(#line) \nNO STRING")
                        return
                    }
                    Logger.TDLOG(toPrint)
                }
            }
            emailTask.resume()
        }
        if let IDFAUrl = buildAppLaunchUrl(isEmail: false) {
            Logger.TDLOG("file \(#file) line \(#line) url: \(IDFAUrl)")
            let IDFATask = session.dataTask(with: IDFAUrl) { (data, response, error) in
                if let resp = response as? HTTPURLResponse {
                    Logger.TDLOG(resp.statusCode.description)
                }
                if let error = error {
                    Logger.TDLOG("\(#function) , line: \(#line)\n \(error.localizedDescription)")
                }
                if let data = data {
                    guard let toPrint = String(data: data, encoding: .utf8) else {
                        Logger.TDLOG("file \(#file) line: \(#line) \nNO STRING")
                        return
                    }
                    Logger.TDLOG(toPrint)
                }
            }
            IDFATask.resume()
        }
    }
    
    func trackInstall(appInstallEventId: String) {
        if !isTrackingEnabled {
            return
        }
        let leadNumber = generateRandomString() + "\(Int64(Date().timeIntervalSince1970))"
        
        if let emailUrl = buildTrackInstallUrl(appInstallEventId: appInstallEventId, leadNumber: leadNumber, isEmail: true) {
            let saleTaskEmail = session.downloadTask(with: emailUrl) { (url1, resp1, err) in
                Logger.TDLOG("SALE REQUEST: \n \(emailUrl)")
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskEmail.resume()
        }
        
        if let IDFAUrl = buildTrackInstallUrl(appInstallEventId: appInstallEventId, leadNumber: leadNumber, isEmail: false) {
            let saleTaskIDFA = session.downloadTask(with: IDFAUrl) { (url1, resp1, err) in
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskIDFA.resume()
        }
    }
    
    private func buildTrackInstallUrl(appInstallEventId: String, leadNumber: String, isEmail: Bool) -> URL? {
        if isEmail && settings.userEmail == nil {
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            return nil
        }
        var components = URLComponents()
        components.host = "https://tbl.tradedoubler.com"
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
    
    
    func trackSale(eventId: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: ReportInfo?) {
        if !isTrackingEnabled {
            return
        }
        
        if let emailUrl = buildTrackSaleUrl(eventId: eventId, currency: currency, orderValue: orderValue, reportInfo: reportInfo, isEmail: true) {
            let saleTaskEmail = session.downloadTask(with: emailUrl) { (url1, resp1, err) in
                Logger.TDLOG("SALE REQUEST: \n \(emailUrl)")
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskEmail.resume()
        }
        
        if let IDFAUrl = buildTrackSaleUrl(eventId: eventId, currency: currency, orderValue: orderValue, reportInfo: reportInfo, isEmail: false) {
            let saleTaskIDFA = session.downloadTask(with: IDFAUrl) { (url1, resp1, err) in
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskIDFA.resume()
        }
    }
    
    func trackSalePlt(saleEventId: String, orderNumber: String, currency: String?, voucherCode: String?, basketInfo: BasketInfo) {
        if !isTrackingEnabled {
            return
        }
        
        if let emailUrl = buildTrackSalePltUrl(saleEventId: saleEventId, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, basketInfo: basketInfo, isEmail: true) {
            let saleTaskEmail = session.downloadTask(with: emailUrl) { (url1, resp1, err) in
                Logger.TDLOG("SALE REQUEST: \n \(emailUrl)")
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskEmail.resume()
        }
        
        if let IDFAUrl = buildTrackSalePltUrl(saleEventId: saleEventId, orderNumber: orderNumber, currency: currency, voucherCode: voucherCode, basketInfo: basketInfo, isEmail: false) {
            let saleTaskIDFA = session.downloadTask(with: IDFAUrl) { (url1, resp1, err) in
                if let rsp = resp1 as? HTTPURLResponse {
                    Logger.TDLOG(rsp.statusCode.description)
                }
                if let uuu = url1 {
                    Logger.TDLOG(uuu.absoluteString)
                }
                if let eee = err {
                    Logger.TDLOG(eee.localizedDescription)
                }
            }
            saleTaskIDFA.resume()
        }
        
    }
    
    func trackLead(eventId: String) {
        if !isTrackingEnabled {
            return
        }
        guard let emailUrl = buildTrackLeadUrl(eventId: eventId, isEmail: true) else {return}
        Logger.TDLOG(emailUrl.debugDescription)
        let leadTaskEmail = session.downloadTask(with: emailUrl) { (url1, resp1, err) in
            if let rsp = resp1 as? HTTPURLResponse {
                Logger.TDLOG(rsp.statusCode.description)
            }
            if let uuu = url1 {
                Logger.TDLOG(uuu.absoluteString)
            }
            if let eee = err {
                Logger.TDLOG(eee.localizedDescription)
            }
        }
        leadTaskEmail.resume()
        
        guard let IDFAUrl = buildTrackLeadUrl(eventId: eventId, isEmail: false) else {return}
        Logger.TDLOG(IDFAUrl.debugDescription)
        let leadTaskIDFA = session.downloadTask(with: IDFAUrl) { (url1, resp1, err) in
            if let rsp = resp1 as? HTTPURLResponse {
                Logger.TDLOG(rsp.statusCode.description)
            }
            if let uuu = url1 {
                Logger.TDLOG(uuu.absoluteString)
            }
            if let eee = err {
                Logger.TDLOG(eee.localizedDescription)
            }
        }
        leadTaskIDFA.resume()
    }
    
    /*func oldLeadRequest(organization: String, event: String, leadNo: String, checkSum: String? = nil, identifier: String, limitTracking: Bool, isEmail: Bool) {
        print("http://tbl.tradedoubler.com/report?organization=\(organization)&event=\(event)&leadNumber=\(leadNo)&checksum=\(checkSum)&deviceid=\(identifier.sha256())&limitAdTracking=\(limitTracking)")
    }*/
    
    func countChecksum(secretCode: String, orderNumber: String, orderValue: String) -> String {
        let prefix = "v04"
        let suffix = secretCode + orderNumber + orderValue
        return prefix + suffix.md5()
    }
    
    // if has idfa send with idfa if email - send with email. Send both if available
    func ceateAppInstallStep(organizationId: String, eventId: String, email: String? = nil, IDFA: String? = nil, isEmail: Bool) -> URL? {
        let tduid = settings.tduid
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
        TradeDoublerSDKSettings.shared.orderNumber = ""
        if tduid != nil {
            queryItems.append(URLQueryItem(name: "tduid", value: tduid))
        }
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        components.queryItems = queryItems
        return components.url
        
    }
    
    private func generateRandomString() -> String {
        let length = 6
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let quantity = UInt32(letters.count)
        var toReturn = ""
        for _ in 0 ..< length {
            let randomNo = Int(arc4random_uniform(quantity))
            let character = letters.trimToCharAtIndex(index: randomNo)
            toReturn += character
        }
        return toReturn
    }
    
    /// For email login: isEmail must be true & user parameter is set to email address
    /// For IDFA usage: isEmail set to false & user parameter is IDFA string
    /// Developer should default to email if user refuses to use IDFA in settings (or redirect to settings requesting user consent)
    private func buildAppLaunchUrl(isEmail: Bool) -> URL? {
        guard let organizationId = settings.organizationId else {
            Logger.TDLOG("no organization ID on launch, please set organization ID before calling trackOpenApp()")
            return nil
        }
        let mail = TradeDoublerSDKSettings.shared.userEmail
        let IDFA = TradeDoublerSDKSettings.shared.IDFA
        let host = "tbl.tradedoubler.com"
        if mail == nil && isEmail && IDFA == nil {
            Logger.TDLOG("no email on launch")
            return nil
        }
        if !isEmail && IDFA == nil {
            Logger.TDLOG("no IDFA on launch")
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
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        if let tduid = TradeDoublerSDKSettings.shared.tduid {
            queryItems.append(URLQueryItem(name: "tduid", value: tduid))
        }
        queryItems.append(URLQueryItem(name: "verify", value: "true"))
        components.queryItems = queryItems
        return components.url
    }
    
    private func buildTrackLeadUrl(eventId: String, isEmail: Bool) -> URL? {
        var components = URLComponents()
        guard let organizationId = settings.organizationId else {
            Logger.TDLOG("creating sale tracking step. Aborted because organizationId is null")
            return nil
        }
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: TradeDoublerSDKSettings.shared.orderNumber))
        TradeDoublerSDKSettings.shared.orderNumber = ""
        queryItems.append(URLQueryItem(name: "extid", value: isEmail ? settings.userEmail : settings.IDFA))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        components.queryItems = queryItems
        return components.url!
    }
    
    private func buildTrackSaleUrl(eventId: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: ReportInfo?, isEmail: Bool) -> URL? {
        guard let organizationId = settings.organizationId, let secretCode = settings.secretCode else {
            Logger.TDLOG("creating sale tracking step. Aborted because of at least one obligatory parameter being null.\norganizationId = \(settings.organizationId ?? "null"), secretCode = \(settings.secretCode ?? "null")")
            return nil
        }
        
        let mail = settings.userEmail
        let IDFA = settings.IDFA
        let user: String
        if isEmail {
            if mail == nil {
                Logger.TDLOG("no email on launch")
                return nil
            } else {
                user = mail!
            }
        } else {
            if IDFA == nil {
                Logger.TDLOG("no IDFA on launch")
                return nil
            } else {
                user = IDFA!
            }
        }
        
        let checksum = countChecksum(secretCode: secretCode, orderNumber: TradeDoublerSDKSettings.shared.orderNumber, orderValue: orderValue)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "orderNumber", value: TradeDoublerSDKSettings.shared.orderNumber))
        queryItems.append(URLQueryItem(name: "orderValue", value: orderValue))
        queryItems.append(URLQueryItem(name: "currency", value: "EUR"))
        queryItems.append(URLQueryItem(name: "checksum", value: checksum))
        TradeDoublerSDKSettings.shared.orderNumber = ""
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        if currency != nil {queryItems.append(URLQueryItem(name: "currency", value: currency))}
        if voucher != nil {queryItems.append(URLQueryItem(name: "voucher", value: voucher))}
        if reportInfo != nil {queryItems.append(URLQueryItem(name: "reportInfo", value: reportInfo?.toEncodedString()))}
        components.queryItems = queryItems
        return components.url
    }
    
    private func buildTrackSalePltUrl(saleEventId: String, orderNumber: String, currency: String?, voucherCode: String?, basketInfo: BasketInfo, isEmail: Bool) -> URL? {
        guard let organizationId = settings.organizationId else {
            Logger.TDLOG("organizationId is null, func: \(#function)")
            return nil
        }
        if isEmail && settings.userEmail == nil {
            return nil
        }
        if !isEmail && settings.IDFA == nil {
            return nil
        }
        var checksum: String? = nil
        if let secretCode = settings.secretCode {
            checksum = countChecksum(secretCode: secretCode, orderNumber: orderNumber, orderValue: basketInfo.orderValue())
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
        let toReturn = URL.init(string: queryParam)
        Logger.TDLOG("\(#function) returned \(toReturn.debugDescription)")
        return toReturn
    }
}

class TemporarySessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    private override init() {}
    static let shared = TemporarySessionDelegate()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            Logger.TDLOG(url)
            let components = URLComponents(string: url)
            guard let maybeTduid = components?.queryItems?.filter({ (item) -> Bool in
                item.name == tduidKey
            }) else {
                let task = session.dataTask(with: URLRequest.init(url: request.url!)) { (dt, re, er) in
                    if let resp = re as? HTTPURLResponse {
                        Logger.TDLOG(resp.statusCode.description)
                    }
                    if let err = er {
                        Logger.TDLOG(err.localizedDescription)
                    }
                    if let daata = dt {
                        guard let toPrint = String(data: daata, encoding: .utf8) else {
                            Logger.TDLOG("file \(#file) line: \(#line) \nNO STRING")
                            return
                        }
                        Logger.TDLOG(toPrint)
                    }
                }
                task.resume()
                return
            }
            if let tduid = maybeTduid.first {
                let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [tduidKey : tduid.value!, recoveredKey: false])
                DispatchQueue.main.async {
                    TradeDoublerSDKSettings.shared.tduid = tduid.value
                    NotificationCenter.default.post(toPost)
                }
            }
        }
        
    }
    
}
