//
//  MainViewController.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit
import RxDataSources

class MainViewController: BaseViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var viewRecentHistory: UIView!
    @IBOutlet weak var labelTitle: UILabel!

    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        reactor?.action.onNext(.setEmptyInput)
        searchBar.backgroundImage = UIImage()
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tableView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
    }
}

extension MainViewController: StoryboardView {
    typealias Reactor = MainViewReactor

    func bind(reactor: MainViewReactor) {

        reactor.state.map { $0.error }
            .subscribe(onNext: { [weak self] error in
                if let error = error {
                    self?.showErrorToast(error)
                }
            }).disposed(by: disposeBag)

        reactor.state.map { $0.isSearching }
            .bind(to: viewRecentHistory.rx.isHidden)
            .disposed(by: disposeBag)

        let appListInfoDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, AppListInfo>>(configureCell: { _, tableView, indexPath, item in
            tableView.separatorStyle = .none
            switch item {
            case let .RecentSearchHistory(history):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecentHistoryCell", for: indexPath) as! RecentHistoryCell
                cell.setHistory(history: history)
                tableView.separatorStyle = .singleLine
                return cell
            case let .Searching(searched):
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
                cell.setName(name: self.searchBar.text ?? "", accordedWord: searched)
                tableView.separatorStyle = .singleLine
                return cell
            case let .SearchedResult(app):
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
                cell.reactor = SearchResultCellReactor(app: app)
                return cell
            }
        })

        reactor.state.map { $0.appListInfoSections }
            .bind(to: tableView.rx.items(dataSource: appListInfoDataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(AppListInfo.self)
        .subscribe(onNext: { item in
            UIView.animate(withDuration: 0.05, animations: {
                self.labelTitle.textColor = .clear
                self.viewTitle.isHidden = true
                self.searchBar.text = item.getAccordedWord()
            })

            if case let .SearchedResult(app) = item {
                if let vc = AppContainer.shared.resolve(DetailViewController.self, argument: app) {
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else {
                reactor.action.onNext(.saveHistory(item.getAccordedWord()))
                reactor.action.onNext(.showSearchedResults(item.getAccordedWord()))
            }
        }).disposed(by: disposeBag)

        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.microseconds(1), scheduler: MainScheduler.instance)
            .map { $0.isEmpty ? Reactor.Action.setEmptyInput : Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.2, animations: {
                    self?.labelTitle.textColor = .clear
                    self?.viewTitle.isHidden = true
                    self?.searchBar.showsCancelButton = true
                })
            }).disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.05, animations: {
                    self?.labelTitle.textColor = .black
                    self?.viewTitle.isHidden = false
                    self?.searchBar.showsCancelButton = false
                })
                self?.searchBar.text?.removeAll()
                reactor.action.onNext(.setEmptyInput)
            }).disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self = self, let name = self.searchBar.text else {
                    return
                }
                self.view.endEditing(true)
                reactor.action.onNext(.saveHistory(name))
                reactor.action.onNext(.showSearchedResults(name))
            }).disposed(by: disposeBag)
    }
}
