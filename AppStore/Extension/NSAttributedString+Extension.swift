//
//  NSAttributedString+Extension.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/20.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

extension NSAttributedString {
    public func height(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
