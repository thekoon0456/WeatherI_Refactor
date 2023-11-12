//
//  UpdateSettingViewController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/26.
//

import UIKit

import RealmSwift
import SnapKit
import Then

class UpdateSettingViewController: UIViewController {
    
    //MARK: - Properties
    
    var weatherViewModel: HomeViewModel?
    private var settingViewModel = SettingProfileViewModel()
    private var textFieldViewModel = TextFieldViewModel()
    private var lastRefreshDate: Date = Date() //백그라운드에서 오래 있으면 홈뷰로
    
    private var alertProfileImage: UIImage? //선택한 이미지
    
    lazy var backgoundImageView = UIImageView().then {
        $0.frame = view.bounds
        $0.image = UIImage(named: weatherViewModel?.todayBackgroundImage
                           ?? BackGroundImage.sunnyNight.randomElement()!)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        //밝아서 검은 색 블러 추가
        var blurView = UIView(frame: view.bounds)
        blurView.backgroundColor = ColorSetting.color
        $0.addSubview(blurView)
    }
    
    private let userSettingLabel = UILabel().then {
        $0.text = "유저 설정하기"
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = .white
    }
    
    private let userNameTextField = CustomTextField(placeHolder: "사용자 이름을 입력해주세요")
    
    private let alertSettingLabel = UILabel().then {
        $0.text = "날씨요정 프로필 설정하기"
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = .white
    }
    
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let alertNameTextField = CustomTextField(placeHolder: "알림을 보낼 프로필의 이름")
    
    private let timeSettingLabel = UILabel().then {
        $0.text = "날씨 알림 설정하기"
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = .white
    }

    private let timeLabel = UILabel().then {
        $0.text = "날씨 알림 추가하기"
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.sizeToFit()
        $0.textColor = .white
    }
    
    private lazy var addAlertTimeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(addAlertTimeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var alertTableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.register(AlertTimeCell.self, forCellReuseIdentifier: CellId.alertTimeCell.rawValue)
        $0.showsVerticalScrollIndicator = false
    }
    
    private lazy var saveButton = SaveButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        $0.addTarget(self, action: #selector(saveSetting), for: .touchUpInside)
    }
    
    private lazy var backGroundTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleTap)
    )
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //첫 등록화면이 아니면 기존 데이터 가져옴
        if !RealmService.shared.readUsers().isEmpty {
            getValues()
        }
        
        configureTextFieldObservers()
        getAddedTime()
        
        //앱이 백그라운드에 있다가 5분이 지나고 다시 들어오면 뷰 업데이트
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Action
    
    @objc func saveSetting() {
        let userName = userNameTextField.text
        let alertName = alertNameTextField.text

        //MARK: - 사진은 nil도 가능하게. 0.8로 파일 크기 줄이기
        let data = alertProfileImage?.jpegData(compressionQuality: 0.7)
        
        //MARK: - 유저 없으면 등록, 있으면 업데이트
        if RealmService.shared.readUsers().isEmpty {
            RealmService.shared.createUser(
                userName: userName,
                alertName: alertName,
                alertImage: data,
                alertTimes: RealmService.shared.convertToList(settingViewModel.alertTimes ?? [])
            )
            print("DEBUG: 유저 생성")
            navigationController?.popViewController(animated: true)
            
        } else {
            RealmService.shared.updateUser(
                userName: userName,
                alertName: alertName,
                alertImage: data,
                alertTimes: RealmService.shared.convertToList(settingViewModel.alertTimes ?? [])
            )
            print("DEBUG: 유저 업데이트")
            navigationController?.popViewController(animated: true)
        }
        print("유저정보 저장됨")
        
        AlertService.shared.userAlertTimes = RealmService.shared.convertToArray(RealmService.shared.readUsers().first?.alertTimes ?? List<AlertTimeEntity>())
    }
    
    func getAddedTime() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("알림추가"),
            object: nil,
            queue: nil
        ) { _ in
            self.alertTableView.reloadData()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func handleSelectPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func addAlertTimeButtonTapped() {
        view.endEditing(true) //키보드 내리기
        
        let controller = SettingAddAlertViewController()
        controller.viewModel = settingViewModel
        let nav = UINavigationController(rootViewController: controller)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(nav, animated: true)
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
    
    func getValues() {
        userNameTextField.text = RealmService.shared.readUsers().first?.userName
        alertNameTextField.text = RealmService.shared.readUsers().first?.alertName
        setPhotoButton()
        getAddedTime()
        
        if let imageData = RealmService.shared.readUsers().first?.alertImage {
            alertProfileImage = UIImage(data: imageData)
        }
    }
    
    func setPhotoButton() {
        if let alertProfileImageData = RealmService.shared.readUsers().first?.alertImage {
            let buttonImage = UIImage(data: alertProfileImageData)?.withRenderingMode(.alwaysOriginal)
            selectPhotoButton.setImage(buttonImage, for: .normal)
            selectPhotoButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
            selectPhotoButton.layer.borderWidth = 3
            selectPhotoButton.layer.cornerRadius = 10
            selectPhotoButton.imageView?.contentMode = .scaleAspectFill
        } else {
            selectPhotoButton.setImage(UIImage(named: "plus_photo"), for: .normal)
        }
    }
    
    func configureUI() {
        navigationItem.title = "유저 / 알림 설정"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.addGestureRecognizer(backGroundTapGesture)
        
        view.addSubview(backgoundImageView)
        view.sendSubviewToBack(backgoundImageView)
        
        view.addSubview(userSettingLabel)
        userSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(userNameTextField)
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(userSettingLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        view.addSubview(alertSettingLabel)
        alertSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(100)
            make.top.equalTo(alertSettingLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(alertNameTextField)
        alertNameTextField.snp.makeConstraints { make in
            make.centerY.equalTo(selectPhotoButton)
            make.right.equalToSuperview().offset(-20)
            make.left.equalTo(selectPhotoButton.snp.right).offset(20)
        }
        
        view.addSubview(timeSettingLabel)
        timeSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(selectPhotoButton.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(addAlertTimeButton)
        addAlertTimeButton.snp.makeConstraints { make in
            make.centerY.equalTo(timeSettingLabel)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        view.addSubview(alertTableView)
        alertTableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.top.equalTo(addAlertTimeButton.snp.bottom).offset(5)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(alertTableView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-40)
            make.width.equalToSuperview().offset(-40)
        }
    }
    
}

//MARK: - TextField 함수
extension UpdateSettingViewController {
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        switch sender {
        case let a where a == userNameTextField:
            textFieldViewModel.userName = sender.text
        case let a where a == alertNameTextField:
            textFieldViewModel.alertName = sender.text
        default:
            break
        }
        
        checkFormStatus()
    }
    
    func checkFormStatus() {
        if textFieldViewModel.formIsValid {
            saveButton.isEnabled = true
            saveButton.backgroundColor = ColorSetting.buttonEnabledColor
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = ColorSetting.buttonDisabledColor
        }
    }
    
    func configureTextFieldObservers() {
        userNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        alertNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}


//MARK: - ImagePicker

extension UpdateSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        clickedPhotoButton(image:image, selected: true)
        dismiss(animated: true)
    }
    
    //이미지 선택 취소시 nil로
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("이미지피커 취소 눌림")
        clickedPhotoButton(image: nil, selected: false)
        dismiss(animated: true)
    }
    
    func clickedPhotoButton(image: UIImage?, selected: Bool) {
        if selected {
            print("사진 선택됨")
            alertProfileImage = image
            selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            selectPhotoButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
            selectPhotoButton.layer.borderWidth = 3
            selectPhotoButton.layer.cornerRadius = 10
            selectPhotoButton.imageView?.contentMode = .scaleAspectFill
        } else {
            print("사진 취소됨")
            alertProfileImage = image
            selectPhotoButton.setImage(UIImage(named: "plus_photo"), for: .normal)
            selectPhotoButton.layer.borderWidth = 0
        }

    }
    
}


//MARK: - TableView

extension UpdateSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingViewModel.alertTimes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.alertTimeCell.rawValue, for: indexPath) as! AlertTimeCell
        cell.viewModel = settingViewModel
        cell.setValue(row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            settingViewModel.alertTimes?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

