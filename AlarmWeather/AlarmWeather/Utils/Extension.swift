//
//  Extension.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import UIKit

import Then
import Lottie


//MARK: - 통신 재시도 Protocol

protocol RetryRequest {
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void, retryCount: Int)
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void)
    func setCustomURLSession(retryRequest: Double) -> URLSession
}

extension RetryRequest {
    //통신 실패시 1초 뒤에 통신 재시도 코드
    func retryRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> Void, retryCount: Int = 0) {
        guard retryCount < 5 else {
            // 실패 횟수가 5번에 도달하면 앱을 종료
            fatalError("Failed to perform network request after 5 retries.")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            performRequest { (result: Result<[T], NetworkError>) in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    // 실패한 경우 재시도를 수행하고 실패 횟수를 증가시킴
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


//MARK: - JSON to Dictionary

extension Encodable {
    var toDictionary : [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}


//MARK: - CustomAnimation

protocol CustomAnimation {
    func weatherAnimation(_ view: UIView)
}

extension CustomAnimation {
    func weatherAnimation(_ view: UIView) {
        UIView.animate(withDuration: 2.5,
                       delay: 0,
                       options: [ .allowUserInteraction,
                                  .repeat,
                                  .curveEaseOut,
                                  .autoreverse]) {
                                      view.alpha = 0.7
                                      view.frame.size = .init(width: view.frame.width, height: view.frame.height - 10)
                                  }
    }
}

extension UIView: CustomAnimation { }

extension UIViewController: CustomAnimation { }


//MARK: - Using Then

extension LottieAnimation: Then { }


//MARK: - NavigationBackButtonItem Disable

class BackBarButtonItem: UIBarButtonItem {
    @available(iOS 14.0, *)
    override var menu: UIMenu? {
        get {
            return super.menu
        }
        set {

        }
    }
}


//MARK: - UILabelLineSpacing

extension UILabel {
    func setLabelTextAndLineSpacing(labelText: String? = nil, lineSpacing: CGFloat) {
        guard let labelText = labelText else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = .center // 중앙 정렬 추가
        
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        self.attributedText = attributedString
    }
}


