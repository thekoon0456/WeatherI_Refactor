//
//  HomeController.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/10.
//

import UIKit
import SnapKit
import Then
import Lottie


final class HomeController: UIViewController {
    
    //MARK: - Properties
    
    weak var dataUpdateDelegate: DataUpdateDelegate?
    
    private let realmManager = RealmService.shared
    
    private var viewUpdate = false
    
    //백그라운드 진입 5분 이후로 새로고침
    private var lastRefreshDate: Date = Date()
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.refreshControl = refreshControl
    }
    
    private let contentView = UIView()
    
    private var todayDateLabel = UILabel().then {
        $0.text = "날짜"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
    }
    
    private lazy var settingButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let image = UIImage(systemName: "gear", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
    }
    
    private var userLabel = UILabel().then {
        $0.text = "안녕하세요 유저님!"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        $0.textAlignment = .left
    }
    
    private var stateLabel = UILabel().then {
        $0.text = "오늘은 맑은 날"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    private var dustStateLabel = UILabel().then {
        $0.text = "미세먼지 보통입니다."
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .left
    }
    
    private var rainStateLabel = UILabel().then {
        $0.text = "오늘 강수 확률은 0% ~ 20% 입니다."
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    private var regionLabel = UILabel().then {
        $0.text = "서울특별시 충무로3가"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    private lazy var weatherAndDustStackView = WetherAndDustStackView().then {
        $0.setValue()
    }
    
    private let todayWeatherLabel = UILabel().then {
        $0.text = "상세 날씨"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var todayDetailWeatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TodayDetailWeatherCell.self, forCellWithReuseIdentifier: CellId.todayDetailWeatherCellId.rawValue)
        return cv
    }()
    
    private let todayTimeWeatherLabel = UILabel().then {
        $0.text = "시간별 날씨"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var todayTimeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TodayTimeWeatherCell.self, forCellWithReuseIdentifier: CellId.todayTimeWeatherCellId.rawValue)
        return cv
    }()
    
    private let weeklyWeatherLabel = UILabel().then {
        $0.text = "주간 날씨"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private lazy var weeklyWeatherTableView = UITableView().then {
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(WeeklyWeatherCell.self, forCellReuseIdentifier: CellId.weeklyWeatherCellId.rawValue)
    }
    
    private let orginLabel = UILabel().then {
        $0.text = "데이터 출처: 기상청, 한국환경공단"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 10, weight: .light)
        $0.textAlignment = .left
    }
    
    private lazy var backgoundImageView = UIImageView().then {
        $0.frame = view.bounds
        $0.image = UIImage(named: viewModel.todayBackgroundImage)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        //밝아서 검은 색 블러 추가
        var blurView = UIView(frame: view.bounds)
        blurView.backgroundColor = ColorSetting.color
        $0.addSubview(blurView)
    }
    
    private lazy var refreshControl = UIRefreshControl().then {
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    //MARK: - ViewModel
    var viewModel = HomeViewModel()
    var dustViewModel = DustViewModel()
    var todayWeather: WeatherModel?
    var todayDust: DustModel?
    var todayDetailWeather = [TodayDetailWeatherModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                todayTimeCollectionView.reloadData()
                print("DEBUG: todayDetailData Loading 성공")
            }
        }
    }
    
    var weeklyWeather = [WeeklyWeatherModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                weeklyWeatherTableView.reloadData()
                print("DEBUG: weeklyWeather Loading 성공")
            }
        }
    }

    var weeklyWeatherTemp = [WeeklyWeatherTempModel]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                weeklyWeatherTableView.reloadData()
                print("DEBUG: weeklyWeatherTemp Loading 성공")
            }
        }
    }

    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue()
        configureUI()
//        //앱이 백그라운드에 있다가 5분이 지나고 다시 들어오면 뷰 업데이트
//        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground),
//                                               name: UIApplication.willEnterForegroundNotification,
//                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //홈뷰에 진입하면 가장 위 메인 화면으로 자동 스크롤
        scrollViewToTop()
        
        //처음엔 viewDidLoad는 실행하지 않아서 업데이트 중복 방지
        if viewUpdate == true {
            autoDataUpdate()
        }
        viewUpdate = true
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }

    
    //MARK: - Actions
    
    @objc func settingButtonTapped() {
        let vc = SettingController()
        vc.weatherViewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
        print("설정뷰 띄우기")
    }
    
    @objc func refreshData() {
        print("DEBUG: refreshable 실행")
        //새로고침하면 화면 가장 처음으로 올림
        scrollViewToTop()
        
        //rootVc의 updateData 실행
        dataUpdateDelegate?.updateData()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("데이터업데이트완료"), object: nil, queue: nil) { _ in
//            guard let self = self else { return }
//            //업데이트시 배경화면도 업데이트 가능
//            backgoundImageView.image = UIImage(named: viewModel.todayBackgroundImage)
            print("DEBUG: 화면 업데이트 완료")
            NotificationCenter.default.removeObserver(self)
//            self.refreshControl.endRefreshing() //업데이트 종료시 refresh종료할 수 있지만 조금 느림
        }
        
        //2.5초 뒤에 refreshable 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    //화면 재진입시 처음 화면으로
    func scrollViewToTop() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    //백그라운드 진입 시간 5분 지나면 데이터 업데이트
    private func autoDataUpdate() {
        let elapsedTime = Date().timeIntervalSince(lastRefreshDate)
        let refreshInterval: TimeInterval = 5 * 60 // 5분
        if elapsedTime >= refreshInterval {
            refreshData()
            // 백그라운드 진입 시간 업데이트
            lastRefreshDate = Date()
        }
    }
    
    //todayDateLabel 최근 시간으로 가져오기
    private func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "M월 d일  E  a h:mm" // "yyyy-MM-dd HH:mm:ss"
        
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow)
        let date = dateFormatter.string(from: dateCreatedAt)
        self.todayDateLabel.text = "\(date)"
    }
    
    
    //MARK: - Helpers
    
    func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: todayDateLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
        let backButton = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        //배경화면
        view.addSubview(backgoundImageView)
        view.sendSubviewToBack(backgoundImageView)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.snp.edges)
            make.height.greaterThanOrEqualTo(scrollView.snp.height).priority(.low)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(userLabel)
        userLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        
        contentView.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(userLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        
        contentView.addSubview(dustStateLabel)
        dustStateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(stateLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        
        contentView.addSubview(rainStateLabel)
        rainStateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(dustStateLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        
        contentView.addSubview(regionLabel)
        regionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(rainStateLabel.snp.bottom).offset(40)
        }
        
        contentView.addSubview(weatherAndDustStackView)
        weatherAndDustStackView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(regionLabel.snp.bottom).offset(10)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.height.equalTo(200)
        }
        
        contentView.addSubview(todayWeatherLabel)
        todayWeatherLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherAndDustStackView.snp.bottom).offset(30)
            make.left.equalTo(contentView.snp.left).offset(15)
        }
        
        contentView.addSubview(todayDetailWeatherCollectionView)
        todayDetailWeatherCollectionView.snp.makeConstraints { make in
            make.top.equalTo(todayWeatherLabel.snp.bottom)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.height.equalTo(200)
        }
        
        contentView.addSubview(todayTimeWeatherLabel)
        todayTimeWeatherLabel.snp.makeConstraints { make in
            make.top.equalTo(todayDetailWeatherCollectionView.snp.bottom).offset(30)
            make.left.equalTo(contentView.snp.left).offset(15)
        }
        
        contentView.addSubview(todayTimeCollectionView)
        todayTimeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(todayTimeWeatherLabel.snp.bottom).offset(20)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.height.equalTo(120)
        }
        
        contentView.addSubview(weeklyWeatherLabel)
        weeklyWeatherLabel.snp.makeConstraints { make in
            make.top.equalTo(todayTimeCollectionView.snp.bottom).offset(50)
            make.left.equalTo(contentView.snp.left).offset(15)
        }
        
        contentView.addSubview(weeklyWeatherTableView)
        weeklyWeatherTableView.snp.makeConstraints { make in
            make.top.equalTo(weeklyWeatherLabel.snp.bottom)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.height.equalTo(560)
        }
        
        contentView.addSubview(orginLabel)
        orginLabel.snp.makeConstraints { make in
            make.top.equalTo(weeklyWeatherTableView.snp.bottom).offset(20)
            make.left.equalTo(contentView.snp.left).offset(25)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    func setValue() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            updateTime()
            backgoundImageView.image = UIImage(named: viewModel.todayBackgroundImage)
            userLabel.text = "안녕하세요" + ((realmManager.readUsers().first?.userName ?? "") != "" ? " \(realmManager.readUsers().first?.userName ?? "")님 😊" : " 😊")
            stateLabel.text = viewModel.todayWeatherMainMent
            dustStateLabel.text = dustViewModel.todayDustMainMent
            rainStateLabel.text = viewModel.todayRainyWeatherMent
            regionLabel.text = LocationService.shared.userRegion
            weatherAndDustStackView.viewModel = viewModel
            weatherAndDustStackView.dustViewModel = dustViewModel
            weatherAndDustStackView.setValue()
        }
        print("DEBUG: 값 구성 완료")
    }
    
}


//MARK: - delegate
extension HomeController: WetherAndDustStackViewDelegate {
    func weatherIconTapped() {
        print("오늘 날씨 모달 띄우기")
        let controller = WeatherController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }
    
    func dustIconTapped() {
        print("오늘 미세먼지 모달 띄우기")
        let controller = DustController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }
}


//MARK: - todayDetailCollectionView

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == todayDetailWeatherCollectionView {
            return CGSize(width: (view.frame.width - 30) / 2, height: 100)
        } else {
            return CGSize(width: view.frame.width / 6, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == todayDetailWeatherCollectionView {
            return 4
        } else {
            return todayDetailWeather.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == todayDetailWeatherCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.todayDetailWeatherCellId.rawValue, for: indexPath) as! TodayDetailWeatherCell
            cell.viewModel = viewModel
            cell.setValue(item: indexPath.item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.todayTimeWeatherCellId.rawValue, for: indexPath) as! TodayTimeWeatherCell
            cell.viewModel = viewModel
            cell.setValue(item: indexPath.item)
            return cell
        }
    }
    
}


//MARK: - WeeklyWeatherTableView extension

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weeklyWeatherTemp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.weeklyWeatherCellId.rawValue, for: indexPath) as! WeeklyWeatherCell
        cell.viewModel = viewModel
        cell.setValue(row: indexPath.row)
        return cell
    }
}
