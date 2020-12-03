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
            if !self.requests.isEmpty {
                self.readRequest()
            }
        }
    }
    
    private func generatePass() -> Data {
        return magicPass.sha256Modified()
    }
    
    private func createJsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requests, options: []) else {
            Logger.TDLog("No data from array in \(#function)")
            return ""
        }
        guard let toReturn = String(data: jsonData, encoding: .utf8) else {
            Logger.TDLog("null string in \(#function)")
            return ""
        }
        return toReturn
    }
    
    func encryptWithAes(_ json: String) -> Data {
        guard let secret = json.data(using: .utf8) else {
            Logger.TDLog("encrypting \(json) failed in \(#function)")
            return Data()
        }
        guard let encr = secret.encryptAES256_CBC_PKCS7_IV(key: generatePass()) else {
            Logger.TDLog("FAILURE on encrypt in \(#function)")
            return Data()
        }
        return encr
    }
    
    func decryptWithAes(_ data: Data?) -> [String] {
        guard let data = data else {
            Logger.TDLog("No data on decrypt in \(#function)")
            return []
        }
        guard let decrypted = data.decryptAES256_CBC_PKCS7_IV(key: generatePass()) else {
            Logger.TDLog("FAILURE on decrypt in \(#function) line \(#line)")
            return []
        }
        guard let toReturn = try? JSONSerialization.jsonObject(with: decrypted, options: []) as? [String] else {
            Logger.TDErrorLog("FAILURE on JSON deserializing in \(#function) line \(#line)")
            return []
        }
        return toReturn
    }
    
    func addRequest(_ requestUrl: URL) {
        addOperation { [weak self] in
            guard let self = self else {return}
            let absoluteStr = requestUrl.absoluteString
            if self.requests.firstIndex(of: absoluteStr) != nil {
                Logger.TDLog("Tried adding the same request more than once, returning")
                return
            }
            Logger.TDLog("appending \(absoluteStr)")
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
            Logger.TDLog("redirecting to \(absoluteStr)")
            guard let current = self.currentRequest, let index = self.requests.firstIndex(of: current) else {
                Logger.TDLog("Redirecting but current request is null or absent on queue (current=\(self.currentRequest.debugDescription), queue \(self.requests.debugDescription)) Redirect aborted.")
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
                Logger.TDLog("Tried to add request but still processing another")
                return
            }
            guard let first = self.requests.first else {
                Logger.TDLog("Tried to add request but nothing enqueued")
                return
            }
            URLHandler.shared.executeURLFromOffline(first)
            self.processing = true
            self.currentRequest = first
        }
        
    }
    
    func requestComplete(_ req : URL? = nil) {
        addOperation { [weak self] in
            guard let self = self else {return}
            defer {
                Logger.TDLog("Finished request, looking for next")
                self.processing = false
                self.readRequest()
            }
            guard let absolute = req?.absoluteString ?? self.currentRequest else {
                Logger.TDLog("WARNING! request complete, URL unknown")
                return
            }
            
            guard let index = self.requests.firstIndex(of: absolute) else {
                Logger.TDLog("\(absolute) finished but already removed from database")
                self.processing = false
                return
            }
            Logger.TDLog("finished \(absolute), removing")
            self.requests.remove(at: index)
            if self.currentRequest != absolute {
                Logger.TDErrorLog("Weird. Finished processing request \(absolute) but current is \(self.currentRequest.debugDescription)")
            }
            self.currentRequest = nil
            UserDefaults.standard.setValue(self.encryptWithAes(self.createJsonString()), forKey: requestsKey)
        }
    }
    
    func requestFailed(_ error: Error, url: URL) {
        addOperation {
            defer {
                self.currentRequest = nil
                self.processing = false
            }
            let absolute = url.absoluteString
            Logger.TDLog("\(absolute) failed. Error: \(error.localizedDescription)")
            if self.currentRequest != absolute {
                Logger.TDErrorLog("Weird. Failed processing request \(absolute) but current is \(self.currentRequest.debugDescription)")
            }
        }
    }
    
    private func addOperation(_ operation: @escaping () -> ()) {
        queue.addOperation(operation)
    }
}
