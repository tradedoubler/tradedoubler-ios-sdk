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
    /// path: for example /users/search
    func getTduid(host: String, path: String, parameters: [String : String]) {
        //https://clk.tradedoubler.com/click?p(310409)a(982247)g(0)
        //https://clk.tradedoubler.com/click?a=982247&p=310409&g=0&f=0
        print("at start we have orderNo = \(DataHandler.shared.orderNumber)")
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
    
    /// For email login: isEmail must be true & user parameter is set to email address
    /// For IDFA usage: isEmail set to false & user parameter is IDFA string
    /// Developer should default to email if user refuses to use IDFA in settings (or redirect to settings requesting user consent)
    private func createAppLaunchStep(organizationId: String, isEmail: Bool) -> URL? {
        let mail = DataHandler.shared.email
        let IDFA = DataHandler.shared.IDFA
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
        if let tduid = DataHandler.shared.tduid {
            queryItems.append(URLQueryItem(name: "tduid", value: tduid))
        }
        queryItems.append(URLQueryItem(name: "verify", value: "true"))
        components.queryItems = queryItems
        return components.url
    }
    
    /*private func createPixelTrackingStep(host:String, organizationId: String, eventId: String, orderOrLeadNo: String, isOrder: Bool, orderValue: String? = nil, currency: String? = nil,/*type - flag for iframe required??,*/ validOn: String? = nil, checksum: String? = nil, reportInfo: String? = nil, user: String? = nil, isEmail: Bool? = nil, voucher: String? = nil) -> URL {
        let tduid = DataHandler.shared.tduid
        
        if tduid == nil {
            Logger.TDLOG("NO TDUID in \(#function)")
        }
        var components = URLComponents()
        if isOrder && orderValue == nil {
            fatalError("Order without order value is illegal!")
        }
        components.scheme = "https"
        components.host = host
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(isOrder ? URLQueryItem(name: "orderNumber", value: orderOrLeadNo) :
                            URLQueryItem(name: "leadNumber", value: orderOrLeadNo))
        if currency != nil {queryItems.append(URLQueryItem(name: "currency", value: currency))}
        if voucher != nil {queryItems.append(URLQueryItem(name: "voucher", value: voucher))}
        if validOn != nil {queryItems.append(URLQueryItem(name: "validOn", value: validOn))}
        if checksum != nil {queryItems.append(URLQueryItem(name: "checksum", value: checksum))}
        if reportInfo != nil {queryItems.append(URLQueryItem(name: "reportInfo", value: reportInfo))}
        if user != nil {queryItems.append(URLQueryItem(name: "extid", value: user!.sha256()))}
        if isEmail != nil {queryItems.append(URLQueryItem(name: "exttype", value: "\(isEmail! ? 1 : 0)"))}
        queryItems.append(URLQueryItem(name: "tduid", value: tduid))
        queryItems.append(URLQueryItem(name: "f", value: "0"))
//        queryItems.append(URLQueryItem(name: "type", value: "iframe"))
        components.queryItems = queryItems
        return components.url!
    }*/
    /*
    /// If isOrder is true you must set orderValue
    /// User & isEmail must be both set or both left not set
    /// If not empty user is email address or IDFA string
    /// currency must be valid ISO-4217 string (or not set)
    /// validOn value must use the format YYYY-MM-DD (as per ISO-8601). Other formats will break the tracking pixel of be handled incorrectly.
    /// checksum is part of Tradedoubler's fraud protection measures and we highly recommend you implement it
    ///reportInfo f1 = product ID f2 = product name f3 = product price f4 = quantity ordered
    ///Use URL encoding and concatenate the name=value pairs into one string. Use "&" (ampersand) to separate properties and "|" (pipe) to separate products. For example:
    /// f1=12345&f2=Product Y&f3=10.99&f4=3|f1=67890&f2=Product Z&f3=1000.00&f4=1
    func pixelTrackingRequest(host:String, organizationId: String, eventId: String, orderOrLeadNo: String, isOrder: Bool, orderValue: String? = nil, currency: String? = nil,/*type - flag for iframe required??,*/ validOn: String? = nil, checksum: String? = nil, reportInfo: String? = nil, tduid: String, user: String? = nil, isEmail: Bool? = nil, voucher: String? = nil) {
        let url = createPixelTrackingStep(host: host, organizationId: organizationId, eventId: eventId, orderOrLeadNo: orderOrLeadNo, isOrder: isOrder, orderValue: orderValue, currency: currency, validOn: validOn, checksum: checksum, reportInfo: reportInfo, user: user, isEmail: isEmail, voucher: voucher)
        let task = session.dataTask(with: url) { (data, response, error) in
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
        task.resume()
    }*/
    //get email & idfa from storage
    func appLaunch(organizationId: String) {
        let emailUrl = createAppLaunchStep(organizationId: organizationId, isEmail: true)
        let IDFAUrl = createAppLaunchStep(organizationId: organizationId, isEmail: false)
        if emailUrl != nil {
            Logger.TDLOG("file \(#file) line \(#line) url: \(emailUrl!)")
            let emailTask = session.dataTask(with: emailUrl!) { (data, response, error) in
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
        if IDFAUrl != nil {
            Logger.TDLOG("file \(#file) line \(#line) url: \(IDFAUrl!)")
            let IDFATask = session.dataTask(with: IDFAUrl!) { (data, response, error) in
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
    
    /*trackDownloadAsSale:(NSString*)organization withEvent:(NSString*)event withSecretCode:(NSString*)secretCode
                    withTimeout:(int)timeout withLifeTimeValueDays:(int)ltvDays withCurrency:(NSString*)currency withOrderValue:(NSString*)orderValue withCookieTracking:(BOOL)cookieTracking
     
     
    func oldSaleRequest(organization: String, event: String, orderNo: String, orderVal: String, currency: String, checkSum: String? = nil, identifier: String, limitTracking: Bool, isEmail: Bool) {
        print("http://tbs.tradedoubler.com/report?organization=\(organization)&event=\(event)&orderNumber=\(orderNo)&orderValue=\(orderVal)&currency=\(currency)&checksum=\(checkSum)&deviceid=\(idfa)&limitAdTracking=\(limitTracking)")
    }*/
     
    private func createSaleTrackingStep(organizationId: String, eventId: String, secretCode: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: String?, isEmail: Bool) -> URL? {
        let mail = DataHandler.shared.email
        let IDFA = DataHandler.shared.IDFA
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
        
        let checksum = countChecksum(secretCode: secretCode, orderNumber: DataHandler.shared.orderNumber, orderValue: orderValue)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "orderNumber", value: DataHandler.shared.orderNumber))
        queryItems.append(URLQueryItem(name: "orderValue", value: orderValue))
        queryItems.append(URLQueryItem(name: "currency", value: "EUR"))
        queryItems.append(URLQueryItem(name: "checksum", value: checksum))
        DataHandler.shared.orderNumber = ""
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        if currency != nil {queryItems.append(URLQueryItem(name: "currency", value: currency))}
        if voucher != nil {queryItems.append(URLQueryItem(name: "voucher", value: voucher))}
//        if validOn != nil {queryItems.append(URLQueryItem(name: "validOn", value: validOn))}
//        if checksum != nil {queryItems.append(URLQueryItem(name: "checksum", value: checksum))}
        if reportInfo != nil {queryItems.append(URLQueryItem(name: "reportInfo", value: reportInfo))}
        components.queryItems = queryItems
        return components.url
    }
    
    func trackSale(organizationId: String, eventId: String, secretCode: String, currency: String?, orderValue:String, voucher: String? = nil, reportInfo: String?, tduid: String, user: String, isEmail: Bool) {/* cookieTracking: Bool, ltvDays: Int)*/
        
        let host = "tbl.tradedoubler.com"
        let emailUrl = createSaleTrackingStep(organizationId: organizationId, eventId: eventId, secretCode: secretCode, currency: currency, orderValue: orderValue, reportInfo: reportInfo, isEmail: true)
        let IDFAUrl = createSaleTrackingStep(organizationId: organizationId, eventId: eventId, secretCode: secretCode, currency: currency, orderValue: orderValue, reportInfo: reportInfo, isEmail: false)
        if emailUrl != nil {
            let saleTaskEmail = session.downloadTask(with: emailUrl!) { (url1, resp1, err) in
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
        Logger.TDLOG("SALE REQUEST: \n \(emailUrl!)")
        
        if IDFAUrl != nil {
            let saleTaskIDFA = session.downloadTask(with: IDFAUrl!) { (url1, resp1, err) in
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
    
    private func createLeadTrackingStep(organizationId: String, eventId: String, secretCode: String, timeout: Int, user: String, isEmail: Bool) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: DataHandler.shared.orderNumber))
        DataHandler.shared.orderNumber = ""
        queryItems.append(URLQueryItem(name: "extid", value: user.sha256()))
        queryItems.append(URLQueryItem(name: "exttype", value: "\(isEmail ? 1 : 0)"))
        components.queryItems = queryItems
        return components.url!
    }
    
    func trackLead(organizationId: String, eventId: String, secretCode: String, timeout: Int, user: String, isEmail: Bool) {
        let url = createLeadTrackingStep(organizationId: organizationId, eventId: eventId, secretCode: secretCode, timeout: timeout, user: user, isEmail: isEmail)
        Logger.TDLOG(url.debugDescription)
        let leadTask = session.downloadTask(with: url) { (url1, resp1, err) in
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
        leadTask.resume()
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
        let tduid = DataHandler.shared.tduid
        let IDFA = DataHandler.shared.IDFA
        let mail = DataHandler.shared.email
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
        let leadNumber = "\(Int64(Date().timeIntervalSince1970))" + generateRandomString(length: 6)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tbl.tradedoubler.com"
        components.path = "/report"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "organization", value: organizationId))
        queryItems.append(URLQueryItem(name: "event", value: eventId))
        queryItems.append(URLQueryItem(name: "leadNumber", value: leadNumber))
        DataHandler.shared.orderNumber = ""
        if tduid != nil {
            queryItems.append(URLQueryItem(name: "tduid", value: tduid))
        }
        queryItems.append(URLQueryItem(name: "extid", value: user))
        queryItems.append(URLQueryItem(name: "exttype", value: "1"))
        components.queryItems = queryItems
        return components.url
        
    }
    
    private func generateRandomString(length: Int) -> String {
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
    
//    func createSaleBracketedStep() -> URL {
//
//    }
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
                    DataHandler.shared.tduid = tduid.value
                    NotificationCenter.default.post(toPost)
                }
            }
        }
//        Logger.TDLOG("got redirect from \(request.url!.absoluteString)")
        
    }
    
}
