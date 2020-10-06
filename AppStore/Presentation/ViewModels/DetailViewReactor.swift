//
//  DetailViewReactor.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift
import ReactorKit

final class DetailViewReactor: Reactor {
    var initialState: State
    typealias Action = NoAction

    init(app: App) {
        var detailContents: [DetailInformationContent] {
            if app.sellerUrl == nil {
                return DetailInformationContent.allCases.filter { $0 != .DeveloperWebsite }
            }
            return DetailInformationContent.allCases
        }
        self.initialState = State(app: app, appIcon: app.getAppIconData(), screenshotDatas: app.getScreenshotDatas(device: .IPHONE), ipadScreenshotDatas: app.getScreenshotDatas(device: .IPAD), detailContents: detailContents)
    }

    struct State {
        var app: App
        var appIcon: Data
        var screenshotDatas: [Data]
        var ipadScreenshotDatas: [Data] = []
        var detailContents: [DetailInformationContent]
    }
}
