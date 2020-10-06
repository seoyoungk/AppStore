//
//  RecentHistoryCell.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

class RecentHistoryCell: UITableViewCell {
    @IBOutlet weak var labelHistory: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labelHistory.font = Utils.getFont(size: 19, bold: false)
    }

    func setHistory(history: String) {
        labelHistory.text = history
    }
}
