//
//  String+Extension.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

extension String {
    func URLEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    func toPartialAlphaString(noneAlphaText: String, basicFontSize: CGFloat, alphaFontSize: CGFloat) -> NSAttributedString {
        let noneAlphaRange = self.range(of: noneAlphaText)

        let wholeAttributedString = NSMutableAttributedString(string: self, attributes: [
            .font: Utils.getFont(size: alphaFontSize, bold: true),
            .foregroundColor: UIColor.black.withAlphaComponent(0.5)
            ])

        if let noneAlphaRange = noneAlphaRange {
            wholeAttributedString.addAttributes([.font: Utils.getFont(size: basicFontSize, bold: true), .foregroundColor: UIColor.black], range: NSRange(noneAlphaRange, in: self))
        }

        return wholeAttributedString
    }

    func toLineSpacedString(lineHeight: CGFloat = 1.2, fontSize: CGFloat = 15, bold: Bool = false, align: NSTextAlignment = .left) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = align
        let attrString = NSMutableAttributedString(string: self, attributes: [
            NSAttributedString.Key.font: Utils.getFont(size: fontSize, bold: bold),
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
        return attrString
    }

    func hasCaseInsensitivePrefix(_ str: String) -> Bool {
        return prefix(str.count).caseInsensitiveCompare(str) == .orderedSame
    }

    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
