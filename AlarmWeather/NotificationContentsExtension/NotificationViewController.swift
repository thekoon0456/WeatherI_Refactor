//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Deokhun KIM on 2023/07/29.
//

import UIKit
import UserNotifications
import UserNotificationsUI

import Lottie
import SnapKit
import Then

final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    //MARK: - Properties
    
    @IBOutlet weak var notiWeatherView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var todayWeatherMent: UILabel!
    @IBOutlet weak var todayDustMent: UILabel!
    @IBOutlet weak var todayTempRangeMent: UILabel!
    @IBOutlet weak var todayPopRangeMent: UILabel!
    @IBOutlet weak var todayItemMent: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var alertName: UILabel!
    
    private var viewModel = HomeViewModel()
    private var dustViewModel = DustViewModel()
    private var todayWeather: WeatherModel?
    private var todayDust: DustModel?
    private var todayDetailWeather = [TodayDetailWeatherModel]()
    private var todayRecommendItems: [String] = []
    
    private var realmData = NotiRealmManager.shared.readUsers()
    
    private let loadingMent = UILabel().then {
        $0.text = Ments.loadingMent.rawValue
        $0.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    }
    
    //MARK: - Lottie
    
    lazy var animationView = LottieAnimationView(name: LottieFiles.loadingView.rawValue).then {
        $0.frame = notiWeatherView.bounds
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop //애니메이션 반복재생
    }
    
    lazy var animationBg = UIView().then {
        $0.backgroundColor = .tertiarySystemBackground
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setAnimationView()
        animationView.play { _ in }
    }
    
    func didReceive(_ notification: UNNotification) {
        
        //이미지가 있으면 이미지를, 없으면 기본 이미지를 알림창에 표시
        if let image = realmData.first?.alertImage {
            profileImageView.image = UIImage(data: image)
        } else {
            profileImageView.image = defaultImage()
        }
        
        guard
            let userInfo = notification.request.content.userInfo as? [String: Any],
            let alertName = userInfo["alertName"] as? String
        else { return }
        
        //데이터를 요청
        loadData { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                //데이터 요청이 완료되면 UI를 구성하고, Animation 종료합니다.
                updateUI(userName: alertName)
                stopAnimation()
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        preferredContentSize = CGSize(width: view.bounds.width, height: 600)
        iconImageView.image = UIImage(named: "appLogo")
        iconImageView.layer.cornerRadius = 10
        iconImageView.clipsToBounds = true
    }
    
    // UI 업데이트를 메인 스레드에서 처리하는 메서드
    private func updateUI(userName: String) {
        let sortedWeatherTmp = todayDetailWeather.sorted { Int($0.tmp) ?? 0 < Int($1.tmp) ?? 0 }
        
        self.alertName.text = "날씨의 i ☀️"
        locationLabel.text = (userName != "" ? "\(userName)님이 보내는"
                              + " 오늘의 \(viewModel.administrativeArea ?? "") 날씨!"
                              : "오늘의 \(viewModel.administrativeArea ?? "") 날씨입니다")
        todayWeatherMent?.text = viewModel.todayWeatherMainMent
        todayDustMent?.text = dustViewModel.todayDustMainMent
        
        if let tmpFirst = sortedWeatherTmp.first?.tmp,
           let tmpLast = sortedWeatherTmp.last?.tmp {
            todayTempRangeMent?.text = "오늘의 온도는 \(tmpFirst)º ~ \(tmpLast)º 입니다"
        }
        
        todayPopRangeMent.text = viewModel.todayRainyWeatherMent
        todayItemMent?.text = viewModel.todayRecommendItems.isEmpty ? "" : "오늘의 추천 아이템:\(viewModel.todayRecommendItems.joined()) \(dustViewModel.todayDustIconName == "aqi.high" ? " 😷" : "")"
    }
    
    func defaultImage() -> UIImage? {
        //낮에는 sunny, 밤에는 night사진
        if todayWeather?.fcstTime ?? "0000" >= "0600" && todayWeather?.fcstTime ?? "0000" <= "2000" {
            return UIImage(named: BackGroundImage.sunny.randomElement()!)
        } else {
            return UIImage(named: BackGroundImage.sunnyNight.randomElement()!)
        }
    }
    
}

extension NotificationViewController {
    //뷰모델 데이터 가져오기
    func loadData(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        self.viewModel.loadTodayWeather { [weak self] model in
            guard let self = self else { return }
            self.todayWeather = model
            print("DEBUG: loadTodayWeather 완료")
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.viewModel.loadTodayDetailWeather { [weak self] model in
            guard let self = self else { return }
            self.todayDetailWeather = model
            print("DEBUG: loadTodayDetailWeather 완료")
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.dustViewModel.loadTodayDust { [weak self] model in
            guard let self = self else { return }
            self.todayDust = model
            print("DEBUG: loadTodayDust 완료")
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("DEBUG: loadData완료")
            completion()
        }
    }
    
}


//MARK: - Lottie

extension NotificationViewController {
    func setAnimationView() {
        notiWeatherView.addSubview(animationBg)
        
        animationBg.addSubview(animationView)
        animationBg.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        animationBg.addSubview(loadingMent)
        loadingMent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(animationView.snp.bottom).offset(-28)
        }
        
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(160)
            make.width.equalTo(160)
        }
    }
    
    func stopAnimation() {
        // 애니메이션 페이드아웃 효과 적용
        UIView.animate(withDuration: 0.2, animations: {
            self.animationView.alpha = 0.0
            self.animationBg.alpha = 0.0
        }) { _ in
            // 애니메이션 중첩 방지를 위해 제거
            self.animationView.stop()
            self.animationBg.removeFromSuperview()
        }
    }
    
}
