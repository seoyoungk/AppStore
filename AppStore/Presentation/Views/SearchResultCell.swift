//
//  SearchResultCell.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Cosmos

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var collectionView: AppCollectionView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnOpen: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var labelReview: UILabel!

    var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.rating = 0
        imgIcon.layer.cornerRadius = 10
        imgIcon.layer.borderWidth = 0.3
        imgIcon.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        btnOpen.layer.cornerRadius = btnOpen.frame.height / 2
    }
}

extension SearchResultCell: StoryboardView {
    typealias Reactor = SearchResultCellReactor

    func bind(reactor: Reactor) {

        reactor.state.map { $0.app.name }
            .bind(to: labelName.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.artistName }
            .bind(to: labelDesc.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { Double($0.app.averageUserRating) }
            .subscribe(onNext: { [weak self] rating in
                self?.ratingView.rating = rating
            }).disposed(by: disposeBag)

        reactor.state.map { $0.app.userRatingCount }
            .subscribe(onNext: { [weak self] count in
                self?.labelReview.text = "\(count.getReviewCount())"
                self?.ratingView.isHidden = count == 0
                self?.labelReview.isHidden = count == 0
            }).disposed(by: disposeBag)

        reactor.state.map { UIImage(data: $0.appIcon) }
            .bind(to: imgIcon.rx.image)
            .disposed(by: disposeBag)

        reactor.state.map { $0.screenshotDatas }
            .bind(to: collectionView.rx.items(cellIdentifier: "ScreenshotsCell", cellType: ScreenshotsCell.self)) { _, item, cell in
                cell.reactor = ScreenshotsCellReactor(screenshot: item)
        }.disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension SearchResultCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = UIScreen.main.bounds.width - 60
        let widthPerItem = availableWidth / 3
        return CGSize(width: widthPerItem, height: widthPerItem * 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
