//
//  WetherAndDustStackView.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/10.
//

import UIKit

import SnapKit
import Then

protocol WetherAndDustStackViewDelegate: AnyObject {
    func weatherIconTapped()
    func dustIconTapped()
}

final class WetherAndDustStackView: UIStackView {
    
    //MARK: - Properties
    
    var viewModel: HomeViewModel?
    var dustViewModel: DustViewModel?
    
    weak var delegate: WetherAndDustStackViewDelegate?
    
    private lazy var weatherView = UIView().then {
        $0.addSubview(weatherIcon)
        $0.addSubview(todayWeatherLabel)
        $0.addSubview(weatherLabel)
        
        weatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(120)
        }
        
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            weatherAnimation(weatherIcon)
//        }
        
        todayWeatherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherIcon.snp.bottom).offset(10)
        }
        
        weatherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(todayWeatherLabel.snp.bottom).offset(15)
        }
    }
    
    private lazy var weatherIcon = UIImageView().then {
        $0.image = UIImage(systemName: "cloud.drizzle")?.withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFill
        
        let tapweatherIcon = UITapGestureRecognizer(target: self, action: #selector(weatherIconTapped))
        $0.addGestureRecognizer(tapweatherIcon)
        $0.isUserInteractionEnabled = true
        $0.addTapZoomAnimation()
    }
    
    private var todayWeatherLabel = UILabel().then {
        $0.text = "맑음"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .white
    }
    
    private var weatherLabel = UILabel().then {
        $0.text = "0" + " " + "℃"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private lazy var dustView = UIStackView().then {
        $0.addSubview(dustIcon)
        $0.addSubview(dustDetailLabel)
        $0.addSubview(dustLabelView)
        
        dustIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(120)
        }
        
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            weatherAnimation(dustIcon)
//        }
        
        dustDetailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dustIcon.snp.bottom).offset(10)
        }
        
        dustLabelView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dustDetailLabel.snp.bottom).offset(15)
        }
        
    }
    
    private lazy var dustIcon = UIImageView().then {
        $0.image = UIImage(systemName: "aqi.medium")?.withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .white
        
        let tapdustIcon = UITapGestureRecognizer(target: self, action: #selector(dustIconTapped))
        $0.addGestureRecognizer(tapdustIcon)
        $0.isUserInteractionEnabled = true
        $0.addTapZoomAnimation()
    }
    
    private var dustDetailLabel = UILabel().then {
        $0.text = "60"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .white
    }
    
    private let dustLabel = UILabel().then {
        $0.text = "미세먼지"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var dustStateLabel = UILabel().then {
        $0.text = " 보통"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private lazy var dustLabelView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
        $0.addArrangedSubview(dustLabel)
        $0.addArrangedSubview(dustStateLabel)
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Actions
    
    @objc func weatherIconTapped() {
        delegate?.weatherIconTapped()
    }
    
    @objc func dustIconTapped() {
        delegate?.dustIconTapped()
    }
    
    
    //MARK: - Helper
    func setValue() {
        weatherIcon.image = UIImage(systemName: viewModel?.todayWeatherIconName ?? "")?.withRenderingMode(.alwaysOriginal)
        todayWeatherLabel.text = viewModel?.todayWeatherLabel
        weatherLabel.text = (viewModel?.todayWeather?.tmp ?? "0") + "º"
        dustIcon.image = UIImage(systemName: dustViewModel?.todayDustIconName ?? "")?.withRenderingMode(.alwaysOriginal)
        dustDetailLabel.text = "PM10: " + (dustViewModel?.todayDust?.pm10Data ?? "")
        dustStateLabel.text = dustViewModel?.todayDust?.dustState ?? ""
        dustStateLabel.textColor = dustViewModel?.todayDustMentColor
    }
    
    private func configureUI() {
        axis = .horizontal
        spacing = 20
        distribution = .fillEqually
        alignment = .center
        
        [weatherView, dustView].forEach { view in
            addArrangedSubview(view)
        }
        
        weatherView.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }

        dustView.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
    }
}
