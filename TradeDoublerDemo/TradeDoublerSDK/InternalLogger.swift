//
//  Converter.swift
//  TradeDoublerSDK
//
//  Created by Adam Tucholski on 28/10/2020.
//

import Foundation

class InternalLogger {
    
    private init() {}
    
    static let shared = InternalLogger()
    
    func urlPassed(url: URL, tduid: String) {
        print("Your tduid to be securely saved & used later is: \(tduid)")
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
    
    private func createPixelTrackingStep(host:String, organizationId: String, eventId: String, orderOrLeadNo: String, isOrder: Bool, orderValue: String? = nil, currency: String? = nil,/*type - flag for iframe required??,*/ validOn: String? = nil, checksum: String? = nil, reportInfo: String? = nil, tduid: String, user: String? = nil, isEmail: Bool? = nil, voucher: String? = nil) -> URL {
        var components = URLComponents()
        if isOrder && orderValue == nil {
            fatalError("Order without order value is illegal!")
        }
        components.scheme = "https"
        components.host = host
        components.path = "/report"
        components.queryItems = [
            URLQueryItem(name: "organization", value: organizationId),
            URLQueryItem(name: "event", value: eventId),
            isOrder ? URLQueryItem(name: "orderNumber", value: orderOrLeadNo) :
            URLQueryItem(name: "leadNumber", value: orderOrLeadNo),
            URLQueryItem(name: "currency", value: currency),
            URLQueryItem(name: "voucher", value: voucher),
            URLQueryItem(name: "validOn", value: validOn),
            URLQueryItem(name: "checksum", value: checksum),
            URLQueryItem(name: "reportInfo", value: reportInfo),
            user != nil ? URLQueryItem(name: "extid", value: user!.sha256()):
                URLQueryItem(name: "extid", value: user),
            isEmail != nil ? URLQueryItem(name: "exttype", value: "\(isEmail! ? 1 : 0)"):
                URLQueryItem(name: "exttype", value: nil),
            URLQueryItem(name: "tduid", value: tduid),
        ]
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
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
