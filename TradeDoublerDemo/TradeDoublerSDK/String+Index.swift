//
//  String+Index.swift
//  TradeDoublerSDK
//
//  Created by AdamT on 25/11/2020.
//

import Foundation

extension String {
    func trimToCharAtIndex(index: Int) -> String {
        if index >= count {
            return ""
        }
        let idx = self.index(startIndex, offsetBy: index)
            return String(self[idx...idx])
    }
}
