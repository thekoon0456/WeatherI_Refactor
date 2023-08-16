//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Deokhun KIM on 2023/07/29.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SnapKit
import Then
import Lottie

////        todayWeatherMent.text = "기분 좋은 맑은 하늘입니다 ☀️"
////        todayDustMent.text = "미세먼지가 좋습니다 😆"
////        todayTempRangeMent.text = "오늘의 온도는 26º ~ 32º 입니다"
////        todayPopRangeMent.text = "오늘 비올 확률은 10% ~ 30% 입니다"
////        todayItemMent.text = "혹시 모르니 우산을 챙겨주세요 ☂️"
///
final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
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
    
    //MARK: - Lottie
    lazy var animationView = LottieAnimationView(name: LottieFiles.loadingView.rawValue).then {
        $0.frame = notiWeatherView.bounds
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop //애니메이션 반복재생
    }
    
    lazy var animationBg = UIView().then {
        $0.backgroundColor = .tertiarySystemBackground
    }
    
    private var viewModel = HomeViewModel()
    private var dustViewModel = DustViewModel()
    private var todayWeather: WeatherModel?
    private var todayDust: DustModel?
    private var todayDetailWeather = [TodayDetailWeatherModel]()
    
    private let loadingMent = UILabel().then {
        $0.text = Ments.loadingMent.rawValue
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setAnimationView()
        animationView.play { _ in }
    }
    
    func didReceive(_ notification: UNNotification) {
        //사진 가져옴
        if let attachment = notification.request.content.attachments.first,
           attachment.url.startAccessingSecurityScopedResource(),
           let imageData = try? Data(contentsOf: attachment.url) {
            profileImageView.image = UIImage(data: imageData)
        } else {
            //시간에 따라 배경 추가
            profileImageView.image = defaultImage()
        }
        
        if let userInfo = notification.request.content.userInfo as? [String: Any],
           let alertName = userInfo["alertName"] as? String,
           let x = userInfo["x"] as? Int,
           let y = userInfo["y"] as? Int,
           let administrativeArea = userInfo["administrativeArea"] as? String {
            print("위치 값 세팅")
            LocationDataService.x = x
            LocationDataService.y = y
            LocationDataService.administrativeArea = administrativeArea
            
            locationLabel.text = alertName != "" ? "\(alertName)님이 보내는" + " 오늘의 \(LocationDataService.administrativeArea) 날씨!" : "오늘의 \(LocationDataService.administrativeArea) 날씨입니다"
            
            loadData { [weak self] in
                guard let self = self else { return }
                // UI 업데이트를 메인 스레드에서 수행
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    updateUI()
                    stopAnimation()
                }
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
    private func updateUI() {
        let sortedWeatherTmp = todayDetailWeather.sorted { $0.tmp < $1.tmp }
        
        alertName.text = "날씨의 i ☀️"
        todayWeatherMent?.text = viewModel.todayWeatherMainMent
        todayDustMent?.text = dustViewModel.todayDustMainMent
        todayTempRangeMent?.text = "오늘의 온도는 \(sortedWeatherTmp.first!.tmp) ~ \(sortedWeatherTmp.last!.tmp) 입니다"
        todayItemMent?.text = viewModel.todayRecommendItems.isEmpty ? "" : "오늘의 추천 아이템:\(viewModel.todayRecommendItems.joined()) \(dustViewModel.todayDustIconName == "나쁨" ? " 😷" : "")"
        
        getRainyMent(model: todayDetailWeather)
    }
    
    func getRainyMent(model: [TodayDetailWeatherModel]) {
        let sortedWeatherPop = todayDetailWeather.sorted { $0.pop < $1.pop }

        if sortedWeatherPop.filter({ $0.pty != "0" }).count == 0 {
            todayPopRangeMent?.text = "오늘은 비가 오지 않는대요 😊"
        } else if sortedWeatherPop.filter({ $0.pty == "4" }).count != 0 {
            todayPopRangeMent?.text = "소나기가 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else if sortedWeatherPop.filter({ $0.pop != "0%" }).count != 0 {
            todayPopRangeMent?.text = "오늘 비 올 확률은 \(sortedWeatherPop[0].pop) ~ \(sortedWeatherPop[sortedWeatherPop.count - 1 ].pop) 입니다 🌧️"
        } else if sortedWeatherPop.filter({ $0.pty == "2" || $0.pty == "2" }).count != 0 {
            todayPopRangeMent?.text = "하얀 눈이 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else {
            todayPopRangeMent?.text = ""
        }
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
            make.top.equalTo(animationView.snp.bottom).offset(-30)
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
