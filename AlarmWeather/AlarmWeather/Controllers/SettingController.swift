//
//  SettingController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/10.
//

import MessageUI
import UIKit

import SnapKit
import Then

final class SettingController: UIViewController {
    
    //MARK: - Properties
    
    var weatherViewModel: HomeViewModel?
    private var lastRefreshDate: Date = Date() //백그라운드에서 오래 있으면 홈뷰로
    
    var settingMenus = ["유저 / 알림 설정하기",
                        "날씨의 i 페이지 보기",
                        "자주 묻는 Q&A 보기",
                        "개발자 피드백 보내기"]
    
    //TODO: - 여행 알림 설정하기 기능 추가
    
    lazy var backgoundImageView = UIImageView().then {
        $0.frame = view.bounds
        $0.image = UIImage(named: weatherViewModel?.todayBackgroundImage ?? BackGroundImage.sunnyNight.randomElement()!)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        //밝아서 검은 색 블러 추가
        var blurView = UIView(frame: view.bounds)
        blurView.backgroundColor = ColorSetting.color
        $0.addSubview(blurView)
    }
    
    private lazy var settingTableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(SettingCell.self, forCellReuseIdentifier: CellId.settingCellId.rawValue)
        $0.separatorStyle = .none //테이블뷰 구분선 제거
        $0.backgroundColor = .clear
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        //앱이 백그라운드에 있다가 5분이 지나고 다시 들어오면 뷰 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //백그라운드 진입 시간 1분 지나면 홈화면으로
    @objc private func appWillEnterForeground() {
        let elapsedTime = Date().timeIntervalSince(lastRefreshDate)
        let refreshInterval: TimeInterval = DoubleConstant.updateDataTime.rawValue
        if elapsedTime >= refreshInterval {
            //루트 뷰컨으로, 애니메이션x
            self.navigationController?.popToRootViewController(animated: false)
            // 백그라운드 진입 시간 업데이트
            lastRefreshDate = Date()
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        navigationItem.title = "설정"
        let backButton = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        view.addSubview(backgoundImageView)
        view.sendSubviewToBack(backgoundImageView)
        
        view.addSubview(settingTableView)
        settingTableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }

    }
    
    func navigateSettingView(row: Int) {
        switch row {
        case _ where row == 0:
            settingCellTapped(viewController: UpdateSettingViewController())
        case _ where row == 1:
            let url = WeatherIURL.homepage.rawValue
            qAndACellTapped(viewController: WebViewController(url: url))
        case _ where row == 2:
            let url = WeatherIURL.qAndA.rawValue
            qAndACellTapped(viewController: WebViewController(url: url))
        case _ where row == 3:
            sendEmail()
        default:
            break
        }
    }
    
    func settingCellTapped(viewController: UIViewController) {
        (viewController as? UpdateSettingViewController)?.weatherViewModel = weatherViewModel
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func qAndACellTapped(viewController: UIViewController) {
        let nav = UINavigationController(rootViewController: viewController)
        present(nav, animated: true)
    }
    
}

extension SettingController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("settingCell 눌림")
        navigateSettingView(row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingMenus.count //나중에 설정 메뉴 갯수대로
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.settingCellId.rawValue, for: indexPath) as! SettingCell
        cell.settingCellLabel.text = settingMenus[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

