//
//  OnboardingViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/31.
//

import UIKit

import Lottie
import SnapKit
import Then
final class OnboardingViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.numberOfPages = pages.count
        $0.currentPage = 0
        $0.pageIndicatorTintColor = .gray
        $0.currentPageIndicatorTintColor = .white
    }
    
    private lazy var nextButton = SaveButton().then {
        $0.setTitle("다음으로 가기", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private let blurView = UIView().then {
        $0.backgroundColor = ColorSetting.color
        $0.alpha = 0.1
    }
    
    //TODO: -멘트 추가, 적절한 애니메이션 추가
    private lazy var pages: [OnboardingContentViewController] = [
        OnboardingContentViewController(lottieName: LottieFiles.locationView.rawValue, content: Ments.locationView.rawValue, pageIndex: 0),
        OnboardingContentViewController(lottieName: LottieFiles.addUserView.rawValue, content: Ments.addUserView.rawValue, pageIndex: 1),
        OnboardingContentViewController(lottieName: LottieFiles.notificationView.rawValue, content: Ments.notificationView.rawValue, pageIndex: 2)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    private func configureUI() {
        view.backgroundColor = .tertiarySystemBackground
        blurView.sendSubviewToBack(view)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        if pages.first != nil {
            pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.equalTo(view.snp.width).offset(-40)
            make.height.equalTo(360)
        }
        
        view.addSubview(pageController)
        pageController.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pageViewController.view.snp.bottom).offset(5)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-80)
            make.width.equalToSuperview().offset(-40)
        }
        
    }
    
    @objc private func nextButtonTapped() {
        if currentPageIndex() == 2 {
            dismiss(animated: true)
            NotificationCenter.default.post(name: Notification.Name("온보딩뷰종료"), object: nil)
        } else {
            pageController.currentPage += 1
            pageViewController.setViewControllers([pages[pageController.currentPage]], direction: .forward, animated: true, completion: nil)
        }

    }
    
    private func currentPageIndex() -> Int? {
        guard let currentPage = pageViewController.viewControllers?.first as? OnboardingContentViewController else {
            return nil
        }
        return currentPage.pageIndex
    }

}

extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            if completed {
                // 페이지 전환 완료 후, 현재 페이지 인덱스를 가져와서 UIPageControl의 currentPage를 업데이트
                if let currentViewController = pageViewController.viewControllers?.first as? OnboardingContentViewController {
                    pageController.currentPage = currentViewController.pageIndex
                }
            }
        }
    }
    
}





