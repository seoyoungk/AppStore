//
//  ScreenshotsCellReactor.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/18.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import ReactorKit
import RxSwift

final class ScreenshotsCellReactor: Reactor {
    var initialState: State
    typealias Action = NoAction

    init(screenshot: Data) {
        self.initialState = State(screenshot: screenshot)
    }

    struct State {
        var screenshot: Data
    }
}
