//
//  AppResponse.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/17.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import Foundation

struct AppResponse: Codable {
    var resultCount: Int
    var results: [App]
}
