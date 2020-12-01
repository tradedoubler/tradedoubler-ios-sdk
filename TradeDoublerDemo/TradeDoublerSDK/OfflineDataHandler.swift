//
//  OfflineDataHandler.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 01/12/2020.
//

import Foundation
import CommonCrypto

let requestsKey = "requestsLaunched"
class OfflineDataHandler {
    let fileName = "encrypted"
    let magicPass = "Minimalistic6&&PassworD!"
    private let manager = FileManager()
    static let shared = OfflineDataHandler()
    let queue = OperationQueue()
    private var processing = false
    var requests = [String]()
    var currentRequest: String?
    
    private init() {
        queue.maxConcurrentOperationCount = 1 //protecting requests array from race condition
        addOperation { [weak self] in
            guard let self = self else {return}
            guard let data = UserDefaults.standard.data(forKey: requestsKey) else {
                self.requests = []
                return
            }
            self.requests = self.decryptWithAes(data)
        }
    }
    
    private func generatePass() -> Data {
        return magicPass.sha256Modified()
    }
    
    private func createJsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requests, options: []) else {
            Logger.TDLOG("No data from array in \(#function)")
            return ""
        }
        guard let toReturn = String(data: jsonData, encoding: .utf8) else {
            print("null string in \(#function)")
            return ""
        }
        return toReturn
    }
    
    func encryptWithAes(_ json: String) -> Data {
        guard let secret = json.data(using: .utf8) else {
            Logger.TDLOG("encrypting \(json) using utf8 failed in \(#function)")
            return Data()
        }
        guard let encr = secret.encryptAES256_CBC_PKCS7_IV(key: generatePass()) else {
            Logger.TDLOG("FAILURE on encrypt in \(#function)")
            return Data()
        }
        return encr
    }
    
    func decryptWithAes(_ data: Data?) -> [String] {
        guard let data = data else {
            Logger.TDLOG("No data on decrypt in \(#function)")
            return []
        }
        guard let decrypted = data.decryptAES256_CBC_PKCS7_IV(key: generatePass()) else {
            Logger.TDLOG("FAILURE on decrypt in \(#function) line \(#line)")
            return []
        }
        guard let toReturn = try? JSONSerialization.jsonObject(with: decrypted, options: []) as? [String] else {
            Logger.TDLOG("FAILURE on JSON deserializing in \(#function) line \(#line)")
            return []
        }
        return toReturn
    }
    
    func addRequest(_ requestUrl: URL) {
        addOperation { [weak self] in
            guard let self = self else {return}
            let absoluteStr = requestUrl.absoluteString
            Logger.TDLOG("appending \(absoluteStr)")
            self.requests.append(absoluteStr)
            UserDefaults.standard.setValue(self.encryptWithAes(self.createJsonString()), forKey: requestsKey)
            if !self.processing {
                self.readRequest()
            }
        }
    }
    
    func performRedirect(_ redirectUrl: URL) {
        addOperation { [weak self] in
            guard let self = self else {return}
            let absoluteStr = redirectUrl.absoluteString
            Logger.TDLOG("redirecting to \(absoluteStr)")
            guard let current = self.currentRequest, let index = self.requests.firstIndex(of: current) else {
                Logger.TDLOG("Redirecting but current request is null or absent on queue (current=\(self.currentRequest.debugDescription), queue \(self.requests.debugDescription)) Redirect aborted.")
                self.currentRequest = nil
                self.processing = false
                return
            }
            self.requests.remove(at: index)
            self.requests.append(absoluteStr)
            UserDefaults.standard.setValue(self.encryptWithAes(self.createJsonString()), forKey: requestsKey)
            self.processing = false
            self.readRequest()
        }
    }
    
    private func readRequest() {
        addOperation { [weak self] in
            guard let self = self else {return}
            if self.processing {
                Logger.TDLOG("Tried to add request but still processing another")
                return
            }
            guard let first = self.requests.first else {
                Logger.TDLOG("Tried to add request but nothing enqueued")
                return
            }
            URLHandler.shared.executeURLFromOffline(first)
            self.processing = true
            self.currentRequest = first
        }
        
    }
    
    func requestComplete(_ req : URL) {
        addOperation { [weak self] in
            guard let self = self else {return}
            defer {
                Logger.TDLOG("Finished request, looking for next")
                self.processing = false
                self.readRequest()
            }
            guard let index = self.requests.firstIndex(of: req.absoluteString) else {
                Logger.TDLOG("\(req) finished but already removed from database")
                self.processing = false
                return
            }
            let absolute = req.absoluteString
            Logger.TDLOG("finished \(absolute), removing")
            self.requests.remove(at: index)
            if self.currentRequest != absolute {
                Logger.TDLOG("Weird. Finished processing request \(absolute) but current is \(self.currentRequest.debugDescription)")
            }
            self.currentRequest = nil
            UserDefaults.standard.setValue(self.encryptWithAes(self.createJsonString()), forKey: requestsKey)
        }
    }
    
    func requestFailed(_ error: Error, url: URL) {
        addOperation {
            let absolute = url.absoluteString
            Logger.TDLOG("\(absolute) failed. Error: \(error.localizedDescription)")
            if self.currentRequest != absolute {
                Logger.TDLOG("Weird. Failed processing request \(absolute) but current is \(self.currentRequest.debugDescription)")
            }
            self.currentRequest = nil
            self.processing = false
        }
    }
    
    private func addOperation(_ operation: @escaping () -> ()) {
        queue.addOperation(operation)
    }
}
