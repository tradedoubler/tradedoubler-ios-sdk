//
//  String+Sha.swift
//  TradeDoublerDemo
//
//  Created by AdamT on 14/11/2020.
//

import Foundation
import CommonCrypto


extension String {
    func sha256() -> String {
        
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = strData.withUnsafeBytes {
            
            CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
        }
        
        var sha256String = ""
        
        for byte in digest {
            sha256String += String(format:"%02x", UInt8(byte))
        }
        
        return sha256String
    }
    
    func sha256Modified() -> Data {
        
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = strData.withUnsafeBytes {
            
            CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
        }
        
        return Data(digest)
    }
    
    func md5() -> String {
        guard let strData = data(using: String.Encoding.utf8) else {fatalError("invalid email")
        }
        var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
        
        _ = strData.withUnsafeBytes {
            
            CC_MD5($0.baseAddress, UInt32(strData.count), &digest)
        }
        var md5String = ""
        
        for byte in digest {
            md5String += String(format:"%02x", UInt8(byte))
        }
        
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
