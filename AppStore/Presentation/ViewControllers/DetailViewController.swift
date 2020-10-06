//
//  DetailViewController.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit
import Cosmos

class DetailViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var btnOpen: UIButton!
    @IBOutlet weak var btnShare: UIButton!

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labelReviewCount: UILabel!
    @IBOutlet weak var labelAverageAge: UILabel!
    @IBOutlet weak var labelAge: UILabel!
    @IBOutlet weak var labelGenreValue: UILabel!
    @IBOutlet weak var labelGenre: UILabel!

    @IBOutlet weak var iPhoneCollectionView: AppCollectionView!
    @IBOutlet weak var iPadCollectionView: AppCollectionView!
    @IBOutlet weak var labelScreenshotTitle: UILabel!
    @IBOutlet weak var labelScreenshotTitleSecond: UILabel!
    @IBOutlet weak var imgIconScreenshot: UIImageView!
    @IBOutlet weak var btnShowIPadScreenshots: UIButton!

    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnShowDescription: UIButton!

    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var labelRateDetail: UILabel!
    @IBOutlet weak var labelReviewCountDetail: UILabel!

    @IBOutlet weak var btnShowDeveloperApp: UIButton!
    @IBOutlet weak var labelDeveloper: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var labelReleaseNote: UILabel!
    @IBOutlet weak var labelReleaseDate: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var defaultHeight: Int = 100
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigtionBar()

        imgIcon.layer.cornerRadius = 20
        btnOpen.layer.cornerRadius = btnOpen.frame.height / 2
        viewDescription.snp.makeConstraints { make in
            make.height.equalTo(defaultHeight)
        }

        tableView.register(UINib(nibName: "InformationCell", bundle: nil), forCellReuseIdentifier: "InformationCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.snp.remakeConstraints { (make) in
            make.height.equalTo(tableView.contentSize.height)
        }
        view.setNeedsUpdateConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func setNavigtionBar() {
        self.navigationItem.titleView?.layer.cornerRadius = 5
        self.navigationItem.titleView?.layer.masksToBounds = true
        self.navigationItem.titleView?.layer.borderWidth = 1
        self.navigationItem.titleView?.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.navigationItem.titleView?.alpha = 0.0
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .systemBlue
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "검색", style: .plain, target: self, action: #selector(self.popVC))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "열기", style: .plain, target: self, action: nil)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    @objc func popVC() {
        self.navigationController?.popViewController(animated: false)
    }
}

extension DetailViewController: StoryboardView {
    typealias Reactor = DetailViewReactor

    func bind(reactor: DetailViewReactor) {

        // MARK:: UI
        scrollView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.name }
            .bind(to: labelName.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.artistName }
            .bind(to: labelArtist.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { UIImage(data: $0.appIcon) }
            .subscribe(onNext: { [weak self] image in
                let imageView = UIImageView()
                imageView.image = image?.resizeImage(targetSize: CGSize(width: 25, height: 25))
                self?.navigationItem.titleView = imageView
                self?.imgIcon.image = image
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.averageUserRating }
            .subscribe(onNext: { [weak self] rating in
                self?.ratingView.rating = rating
                self?.labelRate.isHidden = rating == 0
                self?.labelRate.text = String(format: "%.1f", rating)
                self?.labelRateDetail.text = String(format: "%.1f", rating)
            }).disposed(by: disposeBag)

        reactor.state.map { $0.app.userRatingCount }
            .subscribe(onNext: { [weak self] count in
                self?.viewRate.isHidden = count == 0
                self?.labelReviewCount.text =  count == 0 ? "평가 없음" : count.getReviewCount() + "개의 평가"
                self?.labelReviewCountDetail.text = "\(count.formattedWithSeparator)개의 평가"
            }).disposed(by: disposeBag)

        reactor.state.map { $0.app.genre }
            .bind(to: labelGenre.rx.text )
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.contentAdvisoryRating }
            .bind(to: labelAverageAge.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.ipadScreenshotDatas }
            .subscribe(onNext: { [weak self] datas in
                self?.btnShowIPadScreenshots.isUserInteractionEnabled = !datas.isEmpty
                self?.imgIconScreenshot.isHidden = datas.isEmpty
                self?.labelScreenshotTitle.text = datas.isEmpty ? "iPhone" : "iPad용 앱 제공"
            }).disposed(by: disposeBag)

        reactor.state.map { $0.screenshotDatas }
            .bind(to: iPhoneCollectionView.rx.items(cellIdentifier: "ScreenshotsCell", cellType: ScreenshotsCell.self)) { _, item, cell in
                cell.reactor = ScreenshotsCellReactor(screenshot: item)
                cell.imgView.snp.makeConstraints { make in
                    let height = self.iPhoneCollectionView.frame.height
                    make.width.equalTo(200)
                    make.height.equalTo(height - 10)
                }
        }.disposed(by: disposeBag)

        reactor.state.map { $0.ipadScreenshotDatas }
            .bind(to: iPadCollectionView.rx.items(cellIdentifier: "ScreenshotsCell", cellType: ScreenshotsCell.self)) { _, item, cell in
                cell.reactor = ScreenshotsCellReactor(screenshot: item)
                cell.imgView.snp.makeConstraints { make in
                    let height = self.iPadCollectionView.frame.height
                    make.width.equalTo(300)
                    make.height.equalTo(height - 10)
                }
        }.disposed(by: disposeBag)

        reactor.state.map { $0.app.description.toLineSpacedString(lineHeight: 1.4) }
            .bind(to: labelDescription.rx.attributedText)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.artistName }
            .bind(to: labelDeveloper.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { "버전 \($0.app.version)" }
            .bind(to: labelVersion.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.formattedReleaseDate }
            .bind(to: labelReleaseDate.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.app.releaseNotes }
            .bind(to: labelReleaseNote.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.detailContents }
            .bind(to: tableView.rx.items(cellIdentifier: "InformationCell", cellType: InformationCell.self)) { (_, item, cell) in
                cell.reactor = InformationCellReactor(type: item, app: reactor.currentState.app)
        }.disposed(by: disposeBag)


        // MARK:: Action
        btnShare.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let activityVC = UIActivityViewController(activityItems: [reactor.currentState.app.shareUrl], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                activityVC.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
                self.present(activityVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)

        btnShowIPadScreenshots.rx.tap
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.05, animations: {
                    self?.imgIconScreenshot.isHidden = true
                    self?.btnShowIPadScreenshots.isUserInteractionEnabled = false
                    self?.labelScreenshotTitle.text = "iPhone"
                    self?.iPadCollectionView.isHidden = false
                    self?.labelScreenshotTitleSecond.isHidden = false
                })
            }).disposed(by: disposeBag)

        btnShowDescription.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.btnMore.isHidden = true
                self?.labelDescription.numberOfLines = 0
                let attrDesc = reactor.currentState.app.description.toLineSpacedString(lineHeight: 1.4)
                self?.labelDescription.attributedText = attrDesc
                self?.viewDescription.snp.remakeConstraints { make in
                    make.height.equalTo(attrDesc.height(width: UIScreen.main.bounds.width - 40) + 30)
                }
            }).disposed(by: disposeBag)

        btnShowDeveloperApp.rx.tap
            .subscribe(onNext: { _ in
                if let url = URL(string: reactor.currentState.app.artistViewUrl) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }).disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                switch reactor.currentState.detailContents[indexPath.row] {
                case .SupportedDevice, .AdvisoryRating, .Language:
                    self.tableView.beginUpdates()
                    self.tableView.snp.remakeConstraints { make in
                        make.height.equalTo(self.tableView.contentSize.height)
                    }
                    self.tableView.endUpdates()
                    self.view.setNeedsUpdateConstraints()
                case .DeveloperWebsite:
                    if let sellerUrl = reactor.currentState.app.sellerUrl, let url = URL(string: sellerUrl) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.3) {
                self.navigationItem.titleView?.alpha = 1.0
                self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.navigationItem.titleView?.alpha = 0.0
                self.navigationItem.rightBarButtonItem?.tintColor = .clear
            }
        }
    }
}
