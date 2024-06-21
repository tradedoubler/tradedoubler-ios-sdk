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
import CryptoKit


extension String {
    func sha256() -> String {
        
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        let digest = SHA256.hash(data: strData)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func sha256Modified() -> Data {
        
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        
        let digest = SHA256.hash(data: strData)
        return Data(digest)
    }
    
    func md5() -> String {
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        let digest = Insecure.MD5.hash(data: strData)
        let md5String = digest.map { String(format: "%02x", $0) }.joined()
        return md5String
    }
    
    private func pad(toSize: Int) -> String {
      var padded = self
      for _ in 0..<(toSize - count) {
        padded = "0" + padded
      }
        return padded
    }
}
