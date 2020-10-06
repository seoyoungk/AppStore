//
//  SearchCell.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
   @IBOutlet weak var labelName: UILabel!

    func setName(name: String, accordedWord: String) {
        labelName.attributedText = accordedWord.toPartialAlphaString(noneAlphaText: name, basicFontSize: 20, alphaFontSize: 19)
    }
}
