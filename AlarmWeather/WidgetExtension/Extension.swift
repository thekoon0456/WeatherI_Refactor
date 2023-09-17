//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/16.
//

import Foundation

protocol RetryRequest {
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void, retryCount: Int)
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void)
    func setCustomURLSession(retryRequest: Double) -> URLSession
}

extension RetryRequest {
    //통신 실패시 1초 뒤에 통신 재시도 코드
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void, retryCount: Int = 0) {
        guard retryCount < 10 else {
            fatalError("통신 재시도 10회 초과로 앱을 종료합니다.")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            performRequest { (result: Result<[T], NetworkError>) in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    self.retryRequest(completion: completion, retryCount: retryCount + 1)
                }
            }
        }
    }

    func setCustomURLSession(retryRequest: Double) -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = retryRequest
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }
}
