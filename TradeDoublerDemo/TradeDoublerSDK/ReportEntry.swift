//
//  ReportEntry.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 29/11/2020.
//

import Foundation

public class ReportInfo {
    let reportEntries : [ReportEntry]
    init(entries: [ReportEntry]) {
        reportEntries = entries
    }
}

public class ReportEntry {
    let id: String
    let productName: String
    let price: Double
    let quantity: Int
    
    init(id: String, productName: String, price: Double, quantity: Int) {//quantity?
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
        if let priceToUtf8 = "\(price)".cString(using: .utf8) {
            toReturn += (String(utf8String: priceToUtf8) ?? "") + "&f4="
        }
        if let quantityToUtf8 = "\(quantity)".cString(using: .utf8) {
            toReturn += String(utf8String: quantityToUtf8) ?? ""
        }
        return toReturn
    }
}
