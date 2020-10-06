//
//  MainViewReactor.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift
import ReactorKit
import RxCocoa
import RxDataSources

enum AppListInfo {
    case RecentSearchHistory(String) // 최근 검색어
    case Searching(String) // 검색 중
    case SearchedResult(App) // 검색 결과

    func getAccordedWord() -> String {
        switch self {
        case let .RecentSearchHistory(history):
            return history
        case let .Searching(name):
            return name
        case let .SearchedResult(app):
            return app.name
        }
    }
}

final class MainViewReactor: Reactor {
    private let appUseCase: AppUseCase
    private let cacheRepository: CacheRepository

    var initialState: State

    init(appUseCase: AppUseCase, cacheRepository: CacheRepository) {
        self.appUseCase = appUseCase
        self.cacheRepository = cacheRepository
        self.initialState = State(appListInfoSections: [], histories: cacheRepository.getRecentSearchHistory())
    }

    struct State {
        var error: String?
        var isSearching: Bool = false
        var appListInfoSections: [SectionModel<String, AppListInfo>]
        var accordedWords: [String] = [] // 검색 중인 단어와 최근 검색어 중 일치하는 단어들
        var histories: [String] // 최근 검색어
        var results: [App] = [] // 검색 결과
    }

    enum Action {
        case setError(String?)
        case setEmptyInput
        case search(String)
        case saveHistory(String)
        case showSearchedResults(String)
    }

    enum Mutation {
        case setError(String?)
        case setEmptyInput
        case setSearchWords([String])
        case setHistories
        case setResults([App])
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setError(error):
            return .just(.setError(error))
        case .setEmptyInput:
            return .just(.setEmptyInput)
        case let .search(name):
            return self.search(name: name)
        case let .saveHistory(name):
            cacheRepository.saveSearchHistory(name: name)
            return .just(.setHistories)
        case let .showSearchedResults(name):
            return self.searchApp(name: name)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setError(error):
            newState.error = error
        case .setEmptyInput:
            newState.isSearching = false
            newState.appListInfoSections = setRecentSearchInfoSection()
        case let .setSearchWords(names):
            newState.isSearching = true
            newState.appListInfoSections = setAccordedWordInfoSections(names: names)
            newState.accordedWords = names
        case .setHistories:
            newState.histories = cacheRepository.getRecentSearchHistory()
        case let .setResults(results):
            newState.isSearching = true
            newState.appListInfoSections = setResultInfoSections(results: results)
            newState.results = results
        }
        return newState
    }

    func setRecentSearchInfoSection() -> [SectionModel<String, AppListInfo>] {
        let recentSearchHistoryInfo = currentState.histories.map { AppListInfo.RecentSearchHistory($0) }
        let recentSearchHistoryInfoSection = SectionModel<String, AppListInfo>(model: "최근 검색어", items: recentSearchHistoryInfo)
        return [recentSearchHistoryInfoSection]
    }

    func setAccordedWordInfoSections(names: [String]) -> [SectionModel<String, AppListInfo>] {
        let accordedWordInfo = names.map { AppListInfo.Searching($0) }
        let accordedWordInfoSection = SectionModel<String, AppListInfo>(model: "검색 중", items: accordedWordInfo)
        return [accordedWordInfoSection]
    }

    func setResultInfoSections(results: [App]) -> [SectionModel<String, AppListInfo>] {
        let resultInfo = results.map { AppListInfo.SearchedResult($0) }
        let resultInfoSection = SectionModel<String, AppListInfo>(model: "검색 결과", items: resultInfo)
        return [resultInfoSection]
    }

    func search(name: String) -> Observable<Mutation> {
        return .just(.setSearchWords(cacheRepository.getRecentSearchHistory().filter { $0.hasCaseInsensitivePrefix(name) }))
    }

    func searchApp(name: String) -> Observable<Mutation> {
        return appUseCase.search(name: name)
            .do(onError: { [weak self] error in
                self?.action.onNext(.setError(error.localizedDescription))
            })
            .asObservable()
            .map { response in return .setResults(response.results) }
    }
}
