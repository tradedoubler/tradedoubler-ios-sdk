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

public class BasketInfo {
    public var basketEntries: [BasketEntry]
    public init(entries: [BasketEntry]) {
        basketEntries = entries
    }
    
    public func append(_ entry: BasketEntry) {
        basketEntries.append(entry)
    }
    
    func toEncodedString() -> String {
        return basketEntries.map( {
            $0.toEncodedString()
        }).joined(separator: "")
    }
    
    func orderValue() -> String {
        var toReturn = Double(0)
        for entry in basketEntries {
            toReturn += entry.price * Double(entry.quantity)
        }
        return String(format: "%.2f", toReturn)
    }
}

public class BasketEntry {
    let group: String
    let id: String
    let productName: String
    let price: Double
    let quantity: Int
    public init(group: String, id: String, productName: String, price: Double, quantity: Int) {
        self.group = group
        self.id = id
        self.productName = productName
        self.price = price
        self.quantity = quantity
    }
    func toEncodedString() -> String {
        var toReturn = "pr("
        if let groupToUtf8 = group.cString(using: .utf8) {
            toReturn += "gr(\(String(utf8String: groupToUtf8) ?? ""))"
        }
        if let idToUtf8 = id.cString(using: .utf8) {
            toReturn += "i(\(String(utf8String: idToUtf8) ?? ""))"
        }
        if let nameToUtf8 = productName.cString(using: .utf8) {
            toReturn += "n(\(String(utf8String: nameToUtf8) ?? ""))"
        }
        let cutPrice = String(format: "%.2f", price)
        if let valueToUtf8 = cutPrice.cString(using: .utf8) {
            toReturn += "v(\(String(utf8String: valueToUtf8) ?? ""))"
        }
        if let quantityToUtf8 = "\(quantity)".cString(using: .utf8) {
            toReturn += "q(\(String(utf8String: quantityToUtf8) ?? ""))"
        }
        toReturn += ")"
        return toReturn
    }
    
    public var description: String {
        get {
            "Product: \(productName), price \(price), quantity \(quantity). In group \(group) with id \(id)"
        }
    }
}
