//
//  SearchResultCellReactor.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift
import ReactorKit
import RxCocoa

final class SearchResultCellReactor: Reactor {
    var initialState: State
    typealias Action = NoAction

    init(app: App) {
        // maximum 3 screenshots
        let screenshotDatas = Array(app.getScreenshotDatas(device: .IPHONE).prefix(3))
        self.initialState = State(app: app, appIcon: app.getAppIconData(), screenshotDatas: screenshotDatas)
    }

    struct State {
        var app: App
        var appIcon: Data
        var screenshotDatas: [Data]
    }
}
