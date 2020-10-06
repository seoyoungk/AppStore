//
//  InformationCell.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/20.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class InformationCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelDetailDescription: UILabel!

    var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        labelDetailDescription.isHidden = true
        labelDetailDescription.snp.remakeConstraints { make in
            make.height.equalTo(0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            switch reactor?.currentState.type {
            case .SupportedDevice, .AdvisoryRating, .Language:
                UIView.animate(withDuration: 0.05, animations: {
                    self.imgView.isHidden = true
                    self.labelDescription.isHidden = true
                    self.labelDetailDescription.isHidden = false

                    let attrDesc = self.reactor!.currentState.desc.toLineSpacedString()
                    self.labelDetailDescription.attributedText = attrDesc
                    self.labelDetailDescription.snp.remakeConstraints { make in
                        make.height.equalTo(attrDesc.height(width: UIScreen.main.bounds.width - 40))
                    }
                })
            default:
                break
            }
        }
    }
}

extension InformationCell: StoryboardView {
    typealias Reactor = InformationCellReactor

    func bind(reactor: InformationCellReactor) {

        reactor.state.map { $0.type.getTitle() }
            .bind(to: labelTitle.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { ($0.type, $0.app) }
            .subscribe(onNext: { [weak self] (type, app) in
                self?.labelDescription.text = reactor.currentState.desc

                switch type {
                case .SupportedDevice:
                    self?.labelDescription.text = "이 iPhone와(과) 호환"
                    self?.imgView.isHidden = false
                case .Language:
                    var languageDesc: String {
                        if app.languageCodes.count == 1 {
                            return "한국어"
                        }
                        return "한국어 외 \(app.languageCodes.count - 1)개"
                    }
                    self?.labelDescription.text = languageDesc
                    self?.imgView.isHidden = false
                case .AdvisoryRating:
                    self?.imgView.isHidden = false
                case .PrivacyPolicy, .DeveloperWebsite:
                    self?.labelTitle.textColor = .systemBlue
                    self?.imgView.isHidden = true
                default:
                    self?.imgView.isHidden = true
                }
            }).disposed(by: disposeBag)
    }
}
