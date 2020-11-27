//
//  String+UUID.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 26/11/2020.
//

import Foundation
extension String {
    func isNilUUIDString() -> Bool {
        let array = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let toReturn = array.joined()
        let zeroSet = CharacterSet.init(charactersIn: "0")
        if toReturn.rangeOfCharacter(from: zeroSet.inverted) != nil {
            return false
        }
        return true
    }
}
