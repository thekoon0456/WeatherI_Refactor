//
//  OnboardingContentViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/08/06.
//

import UIKit

import Lottie
import SnapKit
import Then

class OnboardingContentViewController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Lottie
    private lazy var animationView = LottieAnimationView(name: LottieFiles.loadingView.rawValue).then {
        $0.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        $0.contentMode = .scaleAspectFill
        $0.loopMode = .loop //애니메이션 반복재생
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .label
    }
    
    var pageIndex = 0
    
    init(lottieName: String, content: String, pageIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        animationView = LottieAnimationView(name: lottieName)
        self.pageIndex = pageIndex
        contentLabel.setLabelTextAndLineSpacing(labelText: content, lineSpacing: 7)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        //애니메이션 로딩뷰
        animationView.play { _ in
            print("애니메이션 로딩 완료")
        }
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalToSuperview()
        }
        
        
        if pageIndex == 2 {
            view.addSubview(contentLabel)
            contentLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(animationView.snp.bottom).offset(-10)
            }
        } else {
            view.addSubview(contentLabel)
            contentLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(animationView.snp.bottom).offset(30)
            }
        }
    }
    
}
