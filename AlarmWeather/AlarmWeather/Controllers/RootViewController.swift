//
//  RootViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/19.
//

import UIKit
import CoreLocation

import Lottie
import SnapKit
import Then


protocol DataUpdateDelegate: AnyObject {
    func updateData()
}

final class RootViewController: UIViewController {
    
    //MARK: - Properties
    private let realmManager = RealmService.shared
    private let alertManager = AlertService.shared
    
    var homeController = HomeController()
    private var viewModel = HomeViewModel()
    private var dustViewModel = DustViewModel()
    private var todayWeather: WeatherModel?
    private var todayDust: DustModel?
    private var todayDetailWeather = [TodayDetailWeatherModel]()
    private var weeklyWeather = [WeeklyWeatherModel]()
    private var weeklyWeatherTemp = [WeeklyWeatherTempModel]()
    
    var updateLocation = true //위치 필요할때만 true로 업데이트
    var isLoading = true //HomeController로 화면전환시 true로
    private let isUserLogin = UserDefaults.standard
    private var loadingTimer: Timer? //로딩 지연시 안내멘트
    private var loadingAlertTimer: Timer?
    
    //MARK: - Lottie
    private lazy var animationView = LottieAnimationView(name: LottieFiles.loadingView.rawValue).then {
        $0.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop //애니메이션 반복재생
    }
    
    private let blurView = UIView().then {
        $0.backgroundColor = ColorSetting.color
        $0.alpha = 0.1
    }
    
    private let loadingMent = UILabel().then {
        $0.text = Ments.loadingMent.rawValue
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private var loadingDelayMent = UILabel().then {
        $0.text = Ments.loadingDelayMent.rawValue
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let alertController = UIAlertController(title: "기상청 서버 응답 오류입니다😭",
                                                    message: "요청 재시도를 하시거나 \n잠시 후에 앱을 재실행해주세요🙏",
                                                    preferredStyle: .alert)
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        //유저디폴트로 앱 첫 진입시 온보딩뷰로
        if shouldShowOnboarding() {
            DispatchQueue.main.async {
                self.presentOnboardingController()
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("온보딩뷰종료"),
                    object: nil,
                    queue: nil
                ) { [weak self] _ in
                    guard let self = self else { return }
                    //유저 디폴트 로그인값 true로
                    isUserLogin.set(true, forKey: "isUserLogin")
                    //위치, 장소 설정
                    setLocationService()
                    setNotification()
                    NotificationCenter.default.removeObserver(self)
                }
            }
        } else {
            setLocationService()
            setNotification()
        }
        //애니메이션 로딩뷰
        setAnimationView()
        animationView.play { [weak self] _ in
            //애니메이션 종료시 로딩 관련 타이머 해제
            self?.timerInvalidate()
            self?.alertController.dismiss(animated: true)
        }
    }
    
    //MARK: - Action
    
    //위치서비스 요청
    func setLocationService() {
        LocationService.shared.manager.delegate = self
        LocationService.shared.manager.requestWhenInUseAuthorization()
        //TODO: -위젯기능 추가시 백그라운드 위치 요청
//        LocationService.shared.manager.requestAlwaysAuthorization()
        print("DEBUG: locationService On")
    }
    
    //Noti 요청
    func setNotification() {
        alertManager.setAuthorization()
        UNUserNotificationCenter.current().delegate = self
    }
    
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
        
        dispatchGroup.enter()
        self.viewModel.loadWeeklyWeather { model in
            self.weeklyWeather = model
            print("DEBUG: loadWeeklyWeather 완료")
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.viewModel.loadWeeklyWeatherTemp { [weak self] model in
            guard let self = self else { return }
            self.weeklyWeatherTemp = model
            print("DEBUG: loadWeeklyWeatherTemp 완료")
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("DEBUG: loadData완료")
            completion()
        }
    }
}


//MARK: - Delegate
extension RootViewController: DataUpdateDelegate {
    func updateData() {
        updateLocation = true
        isLoading = false
        LocationService.shared.manager.startUpdatingLocation()
    }
}


//MARK: - ViewController Setting

extension RootViewController {
    func shouldShowOnboarding() -> Bool {
        return !isUserLogin.bool(forKey: "isUserLogin") //.bool은 기본값으로 false 반환
    }
    
    func presentOnboardingController() {
        let controller = OnboardingViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    //fadeIn으로 홈컨트롤러 나옴
    func presentHomeController() {
        let vc = UINavigationController(rootViewController: homeController)
        vc.view.alpha = 0
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        UIView.animate(withDuration: 0.5) {
            vc.view.alpha = 1
        }
    }
    
    func setHomeControllerAndViewModel() {
        homeController.viewModel = viewModel
        homeController.dustViewModel = dustViewModel
        homeController.todayWeather = todayWeather
        homeController.todayDust = todayDust
        homeController.todayDetailWeather = todayDetailWeather
        homeController.weeklyWeather = weeklyWeather
        homeController.weeklyWeatherTemp = weeklyWeatherTemp
        homeController.dataUpdateDelegate = self
    }
    
    //위치 가져오고, 가져온 위치를 가공하고 API를 요청해 데이터 로드
    func setLocationAndView(location: CLLocation) {
        LocationService.shared.getLocation(location: location) { location in
            LocationService.shared.location = location
            LocationService.shared.locationToString(location: location) { [weak self] in
                guard let self = self else { return }
                loadData() { [weak self] in
                    guard let self = self else { return }
                    //데이터 세팅
                    setHomeControllerAndViewModel()
                    //로딩화면 끝나면 homeController로 이동
                    isLoadingView(isLoading: isLoading)
                }
            }
        }
    }
    
    func isLoadingView(isLoading: Bool) {
        if isLoading == true {
            animationView.removeFromSuperview()
            presentHomeController()
        } else {
            //HomeController refresh시
            homeController.setValue()
            homeController.configureUI()
            NotificationCenter.default.post(name: NSNotification.Name("데이터업데이트완료"), object: nil) //NotificationCenter로 HomeController에 완료 알려줌
        }
    }
}


//MARK: - Lottie

extension RootViewController {
    func setAnimationView() {
        loadingTimer = Timer.scheduledTimer(timeInterval: DoubleConstant.loadingDelayMent.rawValue,
                                            target: self,
                                            selector: #selector(setRetryMent),
                                            userInfo: nil,
                                            repeats: false)
        
        loadingAlertTimer = Timer.scheduledTimer(timeInterval: DoubleConstant.showingLoadingAlert.rawValue,
                                                 target: self,
                                                 selector: #selector(showingAlert),
                                                 userInfo: nil,
                                                 repeats: false)
        
        view.backgroundColor = .tertiarySystemBackground
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(loadingMent)
        loadingMent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
        
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    //5초 경과시 재시도 문구 추가
    @objc func setRetryMent() {
        print("DEBUG: 로딩 5초 경과")
        loadingMent.addSubview(loadingDelayMent)
        loadingDelayMent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loadingMent.snp.bottom).offset(10)
        }
    }
    
    //15초 경과시 종료 알림 띄움
    @objc func showingAlert() {
        let exitAction = UIAlertAction(title: "종료하기", style: .destructive) { _ in
            exit(0)
        }
        
        let retryAction = UIAlertAction(title: "재시도 하기", style: .default) { [weak self] _ in
            self?.alertController.dismiss(animated: true)
        }
        
        alertController.addAction(exitAction)
        alertController.addAction(retryAction)
        present(alertController, animated: true)
    }
    
    func stopAnimation() {
        animationView.stop()
        animationView.removeFromSuperview()
        //멘트 제거
        loadingDelayMent.removeFromSuperview()
    }
    
    func timerInvalidate() {
        //타이머 해제
        loadingTimer?.invalidate()
        loadingTimer = nil
        loadingAlertTimer?.invalidate()
        loadingAlertTimer = nil
        print("DEBUG: loadingTimer: \(String(describing: loadingTimer)), loadingAlertTimer: \(String(describing: loadingAlertTimer)) 해제")
    }
    
}

//MARK: - coreLocation
extension RootViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치 필요할때만 true로 요청
        guard updateLocation else { return }
        updateLocation = false
        
        if let location = locations.last {
            setLocationAndView(location: location)
        }
        
        LocationService.shared.manager.stopUpdatingLocation()
        print("DEBUG: 위치 업데이트 완료")
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: 위치서비스 에러 \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //위치서비스는 background스레드에서 실행
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                print("DEBUG: 위치 서비스 동의 On")
                LocationService.shared.manager.startUpdatingLocation() //위치 시작
            } else {
                print("DEBUG: 위치 서비스 동의 Off")
            }
        }
    }
    
    
}

extension RootViewController: UNUserNotificationCenterDelegate {
    //앱이 foreground에 있을 때 push알림을 받음
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    //알림 세팅 컨트롤러 넣을때 사용
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        let settingsViewController = HomeController()
//        print("DEBUG: openSettingsFor 실행됨")
//        self.present(settingsViewController, animated: true, completion: nil)
//    }
//
//    //backGround에서 push 클릭했을때 호출됨
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
}


