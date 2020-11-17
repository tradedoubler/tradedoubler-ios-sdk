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
        print(url, " in line \(#line) of \(#file)")
        let task = session.dataTask(with: url) { (data, response, error) in
            /*if let redirUrl = response?.url {
                let components = URLComponents.init(url: redirUrl, resolvingAgainstBaseURL: false)
                let item = queryItems.filter { (item) -> Bool in
                    item.name ==
                }
            }*/
            if let redir = response?.url {
                print("gotta \(redir)")
            }
            if let resp = response as? HTTPURLResponse {
                print(resp.statusCode)
            }
            if let error = error {
                print("\(#function) , line: \(#line)\n \(error.localizedDescription)")
            }
            if let data = data {
                guard let toPrint = String(data: data, encoding: .utf8) else {
                    print("file \(#file) line: \(#line) \nNO STRING")
                    return
                }
                print("server answered: \n", toPrint)
                print(toPrint)
            }
        }
        task.resume()
//        print("Your tduid to be securely saved & used later is: \(tduid)")
    }
    
    /// For email login: isEmail must be true & user parameter is set to email address
    /// For IDFA usage: isEmail set to false & user parameter is IDFA string
    /// Developer should default to email if user refuses to use IDFA in settings (or redirect to settings requesting user consent)
    private func createFirstStep(host:String, organizationId: String, user: String, tduid: String, isEmail: Bool) -> URL {
        
        var components = URLComponents()
            components.scheme = "https"
            components.host = host
            components.path = "/user"
            components.queryItems = [
                URLQueryItem(name: "o", value: organizationId),
                URLQueryItem(name: "extid", value: user.sha256()),
                URLQueryItem(name: "exttype", value: "\(isEmail ? 1 : 0)"),
                URLQueryItem(name: "tduid", value: tduid),
                URLQueryItem(name: "verify", value: "true")
            ]
        return components.url!
    }
    
    func randomEvent(organizationId: String, user: String? = nil, isEmail: Bool? = nil) {
        let url = createPixelTrackingStep(host: "tbs.tradedoubler.com", organizationId: organizationId, eventId: "123", orderOrLeadNo: "15", isOrder: false, tduid: DataHandler.shared.tduid!, user: user, isEmail: isEmail)
        
        print("file \(#file) line \(#line) url: ", url)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                print(resp.statusCode)
            }
            if let error = error {
                print("\(#function) , line: \(#line)\n \(error.localizedDescription)")
            }
            if let data = data {
                guard let toPrint = String(data: data, encoding: .utf8) else {
                    print("file \(#file) line: \(#line) \nNO STRING")
                    return
                }
                print(toPrint)
            }
        }
        task.resume()
    }
    private func createPixelTrackingStep(host:String, organizationId: String, eventId: String, orderOrLeadNo: String, isOrder: Bool, orderValue: String? = nil, currency: String? = nil,/*type - flag for iframe required??,*/ validOn: String? = nil, checksum: String? = nil, reportInfo: String? = nil, tduid: String, user: String? = nil, isEmail: Bool? = nil, voucher: String? = nil) -> URL {
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
        queryItems.append(URLQueryItem(name: "type", value: "iframe"))
        components.queryItems = queryItems
        return components.url!
    }
    
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
        let url = createPixelTrackingStep(host: host, organizationId: organizationId, eventId: eventId, orderOrLeadNo: orderOrLeadNo, isOrder: isOrder, orderValue: orderValue, currency: currency, validOn: validOn, checksum: checksum, reportInfo: reportInfo, tduid: tduid, user: user, isEmail: isEmail, voucher: voucher)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                print(resp.statusCode)
            }
            if let error = error {
                print("\(#function) , line: \(#line)\n \(error.localizedDescription)")
            }
            if let data = data {
                guard let toPrint = String(data: data, encoding: .utf8) else {
                    print("file \(#file) line: \(#line) \nNO STRING")
                    return
                }
                print(toPrint)
            }
        }
        task.resume()
    }
    func firstRequest(host:String, organizationId: String, user: String, tduid: String, isEmail: Bool) {
        let url = createFirstStep(host: host, organizationId: organizationId, user: user, tduid: tduid, isEmail: isEmail)
        print("file \(#file) line \(#line) url: ", url)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                print(resp.statusCode)
            }
            if let error = error {
                print("\(#function) , line: \(#line)\n \(error.localizedDescription)")
            }
            if let data = data {
                guard let toPrint = String(data: data, encoding: .utf8) else {
                    print("file \(#file) line: \(#line) \nNO STRING")
                    return
                }
                print(toPrint)
            }
        }
        task.resume()
    }
}

class TemporarySessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    private override init() {}
    static let shared = TemporarySessionDelegate()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            let components = URLComponents(string: url)
            let maybeTduid = components?.queryItems?.filter({ (item) -> Bool in
                item.name == tduidKey
            })
            if let tduid = maybeTduid?.first {
                let toPost = Notification.init(name: tduidFound, object: nil, userInfo: [tduidKey : tduid.value!, recoveredKey: false])
                DispatchQueue.main.async {
                    DataHandler.shared.tduid = tduid.value
                    NotificationCenter.default.post(toPost)
                }
            }
        }
//        print("got redirect from \(request.url!.absoluteString)")
        
    }
    
}
