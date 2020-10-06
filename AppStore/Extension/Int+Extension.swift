//
//  Int+Extension.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/20.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import Foundation

extension Int {
    func getReviewCount() -> String {
        let reviewCount: ((Int) -> (String)) = { (unit) in
            return String(format: "%.1f", Double(self)/Double(unit))
        }

        switch self {
        case 0...999: return "\(self)"
        case 1000...9999: return reviewCount(1000) + "천"
        case 10000...99999999: return reviewCount(10000) + "만"
        default: return "0"
        }
    }
}
