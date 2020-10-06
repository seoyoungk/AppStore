//
//  ScreenshotsCell.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class ScreenshotsCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!

    var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 17
        imgView.layer.masksToBounds = true
        imgView.layer.borderWidth = 0.3
        imgView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }
}

extension ScreenshotsCell: StoryboardView {
    typealias Reactor = ScreenshotsCellReactor

    func bind(reactor: ScreenshotsCellReactor) {

        DispatchQueue.main.async {
            reactor.state.map { UIImage(data: $0.screenshot) }
                .bind(to: self.imgView.rx.image)
                .disposed(by: self.disposeBag)
        }
    }
}
