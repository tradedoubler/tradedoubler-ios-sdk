//Copyright 2019 Chris Hulbert<http://www.splinter.com.au/2019/06/09/pure-swift-common-crypto-aes-encryption/>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CommonCrypto

func randomGenerateBytes(count: Int) -> Data? {
    var bytes = [UInt8](repeating: 0, count: count)
    let result = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    
    guard result == errSecSuccess else { return nil }
    
    return Data(bytes)
}

extension Data {
    func crypt(operation: Int, algorithm: Int, options: Int, key: Data,
            initializationVector: Data, dataIn: Data) -> Data? {
        return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
            return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128*2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize,
                        alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation), CCAlgorithm(algorithm),
                        CCOptions(options),
                        keyUnsafeRawBufferPointer.baseAddress, key.count,
                        ivUnsafeRawBufferPointer.baseAddress,
                        dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                        dataOut, dataOutSize, &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
    
    /// Encrypts for you with all the good options turned on: CBC, an IV, PKCS7
    /// padding (so your input data doesn't have to be any particular length).
    /// Key can be 128, 192, or 256 bits.
    /// Generates a fresh IV for you each time, and prefixes it to the
    /// returned ciphertext.
    func encryptAES256_CBC_PKCS7_IV(key: Data) -> Data? {
            guard let iv = randomGenerateBytes(count: kCCBlockSizeAES128) else { return nil }
            // No option is needed for CBC, it is on by default.
            guard let ciphertext = crypt(operation: kCCEncrypt,
                                        algorithm: kCCAlgorithmAES,
                                        options: kCCOptionPKCS7Padding,
                                        key: key,
                                        initializationVector: iv,
                                        dataIn: self) else { return nil }
            return iv + ciphertext
        }
        
        /// Decrypts self, where self is the IV then the ciphertext.
        /// Key can be 128/192/256 bits.
        func decryptAES256_CBC_PKCS7_IV(key: Data) -> Data? {
            guard count > kCCBlockSizeAES128 else { return nil }
            let iv = prefix(kCCBlockSizeAES128)
            let ciphertext = suffix(from: kCCBlockSizeAES128)
            return crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES,
                options: kCCOptionPKCS7Padding, key: key, initializationVector: iv,
                dataIn: ciphertext)
        }
}
