//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/16.
//

import Foundation

protocol RetryRequest {
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void)
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void)
    func setCustomURLSession(retryRequest: Double) -> URLSession
}

extension RetryRequest {
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            performRequest(completion: completion)
        }
    }

    func setCustomURLSession(retryRequest: Double) -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = retryRequest
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }
}
