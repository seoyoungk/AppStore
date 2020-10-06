//
//  Container.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

final class AppContainer {
    static var shared: Container {
        let container: Container = Container()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

        // Services
        container.autoregister(Network.self, initializer: DefaultNetwork.init)
        container.autoregister(WebAPI.self, initializer: DefaultWebAPI.init)
        container.autoregister(CacheRepository.self, initializer: DefaultCacheRepository.init)

        // UseCases
        container.autoregister(AppUseCase.self, initializer: DefaultAppUseCase.init)

        // Views
        container.register(MainViewController.self) { r in
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            vc.reactor = MainViewReactor(appUseCase: r.resolve(AppUseCase.self)!, cacheRepository: r.resolve(CacheRepository.self)!)
            return vc
        }

        container.register(DetailViewController.self) { (_, app: App) in
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.reactor = DetailViewReactor(app: app)
            return vc
        }

        return container
    }
}
