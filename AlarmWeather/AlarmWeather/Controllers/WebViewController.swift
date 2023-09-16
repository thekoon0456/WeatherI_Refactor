//
//  WebViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/09/16.
//

import UIKit
import WebKit

import SnapKit
import Then

final class WebViewController: UIViewController {
    
    //MARK: - Properties
    
    var url: String
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var webView = WKWebView(frame: view.bounds).then {
        $0.navigationDelegate = self
    }
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.color = .gray
        
        webView.addSubview($0)
        $0.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
    }
    
    private lazy var closeAlertTimeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.addTarget(self, action: #selector(closeAlertTimeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeAlertTimeButtonTapped() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadWebView(url: url)
    }

    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeAlertTimeButton)
        navigationItem.title = "날씨의 i"
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.bottom.right.equalToSuperview()
        }
        
    }
    
    private func loadWebView(url: String) {
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
}
