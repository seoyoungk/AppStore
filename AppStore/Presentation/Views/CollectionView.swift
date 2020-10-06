//
//  CollectionView.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/21.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import RxSwift

class AppCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
    var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.register(UINib(nibName: "ScreenshotsCell", bundle: nil), forCellWithReuseIdentifier: "ScreenshotsCell")

        self.rx.didEndDisplayingCell
            .subscribe(onNext: { _ in
                self.snp.updateConstraints { make in
                    make.height.equalTo(self.contentSize)
                }
            }).disposed(by: disposeBag)
    }
}
