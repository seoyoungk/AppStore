//
//  AppUseCase.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift

protocol AppUseCase {
    func search(name: String) -> Single<AppResponse>
}

final class DefaultAppUseCase: AppUseCase {
    private let api: WebAPI

    init(api: WebAPI) {
        self.api = api
    }

    func search(name: String) -> Single<AppResponse> {
        return api.search(name: name)
    }
}
