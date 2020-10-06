//
//  InformationCellReactor.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/20.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import ReactorKit
import RxSwift

final class InformationCellReactor: Reactor {
    var initialState: State
    typealias Action = NoAction

    init(type: DetailInformationContent, app: App) {
        self.initialState = State(type: type, desc: app.informationContent(type: type), app: app)
    }

    struct State {
        var type: DetailInformationContent
        var desc: String
        var app: App
    }
}
