//
//  BasketInfo.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 01/12/2020.
//

import Foundation

public class BasketInfo {
    let basketEntries: [BasketEntry]
    init(entries: [BasketEntry]) {
        basketEntries = entries
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
        return String(format: "%.02f", toReturn)
    }
}

public class BasketEntry {
    let group: String
    let id: String
    let productName: String
    let price: Double
    let quantity: Int
    init(group: String, id: String, productName: String, price: Double, quantity: Int) {
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
        let cutPrice = String(format: "%.02f", price)
        if let valueToUtf8 = cutPrice.cString(using: .utf8) {
            toReturn += "v(\(String(utf8String: valueToUtf8) ?? ""))"
        }
        if let quantityToUtf8 = "\(quantity)".cString(using: .utf8) {
            toReturn += "q(\(String(utf8String: quantityToUtf8) ?? ""))"
        }
        toReturn += ")"
        return toReturn
    }
}