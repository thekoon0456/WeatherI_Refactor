//
//  SettingAddAlertViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/24.
//

import UIKit
import CoreData
import RealmSwift


final class SettingAddAlertViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: SettingProfileViewModel?
    
    private var alertTime: AlertTimeEntity? = AlertTimeEntity()
    
    var selectedWeeklyIndex = 0
    var selectedTime = Date()
    
    private lazy var daySelectSegmentedControl: UISegmentedControl = {
        let items = ["매일", "주중", "주말"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.tintColor = .white
        control.addTarget(self,
                          action: #selector(segmentedControlValueChanged),
                          for: .valueChanged)
        return control
    }()
    
    private lazy var setAlertTimePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .wheels
        $0.datePickerMode = .time
        $0.locale = Locale(identifier: "ko_kr")
        $0.tintColor = .white
//        $0.minuteInterval = 5 //5분 간격으로 설정
        $0.addTarget(self,
                     action: #selector(datePickerValueChanged),
                     for: .valueChanged)
    }
    
    private lazy var addAlertTimeButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.addTarget(self,
                     action: #selector(addAlertTimeButtonTapped),
                     for: .touchUpInside)
    }
    
    private lazy var closeAlertTimeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.addTarget(self,
                     action: #selector(closeAlertTimeButtonTapped),
                     for: .touchUpInside)
    }
    
    private let blurView = UIView().then {
        $0.backgroundColor = ColorSetting.color
        $0.alpha = 0.1
    }
    
    
    //MARK: - Action
    
    @objc private func addAlertTimeButtonTapped() {
        viewModel?.alertTimes?.append(alertTime ?? AlertTimeEntity())
        print("DEBUG: 시간 추가 \( String(describing: viewModel?.alertTimes))")
        NotificationCenter.default.post(name: NSNotification.Name("알림추가"), object: nil)
        dismiss(animated: true)
    }
    
    @objc private func closeAlertTimeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        selectedWeeklyIndex = sender.selectedSegmentIndex
        alertTime?.weekly = selectedWeeklyIndex
    }
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        selectedTime = sender.date
        alertTime?.time = selectedTime
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        alertTime?.weekly = selectedWeeklyIndex
        alertTime?.time = selectedTime
    }
    
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addAlertTimeButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeAlertTimeButton)
        navigationItem.title = "알람 추가"
        view.backgroundColor = .tertiarySystemBackground
        
        blurView.sendSubviewToBack(view)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        view.addSubview(daySelectSegmentedControl)
        daySelectSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        view.addSubview(setAlertTimePicker)
        setAlertTimePicker.snp.makeConstraints { make in
            make.top.equalTo(daySelectSegmentedControl.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalToSuperview().offset(-40)
        }
    }

}
