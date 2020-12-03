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

public class ReportInfo {
    public var reportEntries : [ReportEntry]
    public init(entries: [ReportEntry]) {
        reportEntries = entries
    }
    
    public func append(_ entry: ReportEntry) {
        reportEntries.append(entry)
    }
    
    func toEncodedString() -> String {
        return reportEntries.map( {
            $0.toEncodedString()
        }).joined(separator: "|")
    }
    
    func orderValue() -> String {
        var toReturn = Double(0)
        for entry in reportEntries {
            toReturn += entry.price * Double(entry.quantity)
        }
        return String(format: "%.2f", toReturn)
    }
}

public class ReportEntry {
    let id: String
    let productName: String
    let price: Double
    let quantity: Int
    
    public init(id: String, productName: String, price: Double, quantity: Int) {//quantity?
        self.id = id
        self.productName = productName
        self.price = price
        self.quantity = quantity
    }
    
    func toEncodedString() -> String {
        var toReturn = "f1="
        if let idToUtf8 = id.cString(using: .utf8) {
            toReturn += (String(utf8String: idToUtf8) ?? "") + "&f2="
        }
        if let nameToUtf8 = productName.cString(using: .utf8) {
            toReturn += (String(utf8String: nameToUtf8) ?? "") + "&f3="
        }
        let cutPrice = String(format: "%.2f", price)
        if let priceToUtf8 = cutPrice.cString(using: .utf8) {
            toReturn += (String(utf8String: priceToUtf8) ?? "") + "&f4="
        }
        if let quantityToUtf8 = "\(quantity)".cString(using: .utf8) {
            toReturn += String(utf8String: quantityToUtf8) ?? ""
        }
        return toReturn
    }
    
    public var description: String {
        get {
            "Product: \(productName), price \(price), quantity \(quantity). Id: \(id)"
        }
    }
}
