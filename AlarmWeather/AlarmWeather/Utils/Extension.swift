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


