//
//  SettingController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/10.
//

import UIKit
import SnapKit
import Then
import MessageUI

let settingCellId = "settingCellId"

final class SettingController: UIViewController {
    
    //MARK: - Properties
    var weatherViewModel: HomeViewModel?
    private var lastRefreshDate: Date = Date() //백그라운드에서 오래 있으면 홈뷰로
    
    var settingMenus = ["유저 / 알림 설정하기", "개발자 피드백 보내기"]
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
        $0.register(SettingCell.self, forCellReuseIdentifier: settingCellId)
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
    
    //백그라운드 진입 시간 1분 지나면 홈화면으로
    @objc private func appWillEnterForeground() {
        let elapsedTime = Date().timeIntervalSince(lastRefreshDate)
        let refreshInterval: TimeInterval = 1 * 60 // 5분
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
            sendEmail()
        default:
            break
        }
    }
    
    func settingCellTapped(viewController: UIViewController) {
        (viewController as? UpdateSettingViewController)?.weatherViewModel = weatherViewModel
        navigationController?.pushViewController(viewController, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: settingCellId, for: indexPath) as! SettingCell
        cell.settingCellLabel.text = settingMenus[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}


//MARK: - MessageUI 이메일

extension SettingController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients(["thekoon0456@gmail.com"]) // 수신자 이메일 주소
            mailController.setSubject("[날씨의 i] 개선 제안") // 이메일 제목
            mailController.setMessageBody("다양한 의견을 보내주시면 앱을 만드는데 큰 보탬이 됩니다. 감사합니다.", isHTML: false) // 이메일 내용
            present(mailController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { action in print("확인") }
        sendMailErrorAlert.addAction(confirmAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("이메일 보내기 취소")
        case .sent:
            print("이메일 보내기 성공")
        case .saved:
            print("이메일이 저장되었습니다.")
        case .failed:
            print("이메일 보내기 실패")
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
