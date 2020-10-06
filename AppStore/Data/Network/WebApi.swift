//
//  WebApi.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/16.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift

protocol WebAPI {
    func search(name: String) -> Single<AppResponse>
}

final class DefaultWebAPI: WebAPI {
    let network: Network

    init(network: Network) {
        self.network = network
    }

    func search(name: String) -> Single<AppResponse> {
        return network.get("https://itunes.apple.com/search?country=kr&media=software&term=\(name)", responseType: AppResponse.self)
    }
}
