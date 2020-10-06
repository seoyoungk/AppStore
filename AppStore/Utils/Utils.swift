//
//  Utils.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

class Utils {
    class func getFont(size: CGFloat = 17.0, bold: Bool = false) -> UIFont {
        if bold {
            return UIFont.boldSystemFont(ofSize: size)
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
}
