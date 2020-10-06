//
//  DefaultNetwork.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/16.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import RxSwift

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

enum NetworkError: Error, LocalizedError {
    case invalidPath
    case networkError
}

protocol Network {
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
}

extension Network {
    func get<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return get(path, parameters: nil, responseType: T.self)
    }
}

class DefaultNetwork: Network {
    private func request<T: Codable>(_ path: String, method: HTTPMethod, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return Single.create { single in
            guard let url = URL(string: path.URLEncode()) else {
                single(.error(NetworkError.invalidPath))
                return Disposables.create()
            }

            var urlRequest = URLRequest(url: url, timeoutInterval: 15)
            urlRequest.httpMethod = method.rawValue

            if let parameter = parameters, let param = try? JSONSerialization.data(withJSONObject: parameter, options: []) {
                urlRequest.httpBody = param
            }

            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil, let data = data, response?.isSuccessResponse() == true else {
                    single(.error(NetworkError.networkError))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(T.self, from: data)
                    single(.success(value))
                } catch {
                    single(.error(error))
                }
            }.resume()
            return Disposables.create()
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
        .observeOn(MainScheduler.asyncInstance)
    }

    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .GET, parameters: parameters, responseType: T.self)
    }
}

extension URLResponse {
    func isSuccessResponse() -> Bool {
        guard let response = self as? HTTPURLResponse else {
            return false
        }
        return response.statusCode >= 200 && response.statusCode < 300
    }
}
