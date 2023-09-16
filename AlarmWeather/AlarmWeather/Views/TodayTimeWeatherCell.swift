//
//  TodayWeatherCell.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import UIKit

import SnapKit
import Then

final class TodayTimeWeatherCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: HomeViewModel?
    
    private var timeLabel = UILabel().then {
        $0.text = "03:00"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .white
    }

    private var weatherIcon = UIImageView().then {
        $0.image = UIImage(systemName: "cloud.drizzle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFill
    }
    
    private var probabilityLabel = UILabel().then {
        $0.text = "60"+"%"
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .white
    }

    private var tempLabel = UILabel().then {
        $0.text = "29"+"º"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .white
    }
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers

    func setValue(item: Int) {
        //날짜 변경시 표시
        if viewModel?.todayDetailWeather?[item].fcstTime == "00:00" || viewModel?.todayDetailWeather?[item].fcstTime == "01:00" {
            timeLabel.text = "\(viewModel?.todayDetailWeather?[item].fcstDate ?? "")"
        } else {
            timeLabel.text = viewModel?.todayDetailWeather?[item].fcstTime
        }
        
        weatherIcon.image = UIImage(systemName: (viewModel?.todayDetailWeatherIconName[item]) ?? "")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        if let pop = viewModel?.todayDetailWeather?[item].pop {
            probabilityLabel.text = pop != "0" ? pop + "%" : ""
        }
        
        if let tmp = viewModel?.todayDetailWeather?[item].tmp {
            tempLabel.text = tmp + "º"
        }

    }
    
    func configureUI() {
        backgroundColor = .clear
        
        [timeLabel, weatherIcon, probabilityLabel, tempLabel].forEach { addSubview($0) }

        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        weatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            weatherAnimation(weatherIcon)
//        }

        probabilityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherIcon.snp.bottom).offset(15)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
}
