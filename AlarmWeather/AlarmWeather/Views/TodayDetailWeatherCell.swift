//
//  TodayDetailWeatherCell.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/18.
//

import UIKit

import SnapKit
import Then

final class TodayDetailWeatherCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: HomeViewModel?
    
    private lazy var weatherIconNames = ["humidity",
                            "umbrella.percent",
                            "wind",
                            viewModel?.todayWeather?.sno == "적설없음" ? "cloud.rain" : "cloud.snow"]
    
    private lazy var weatherLabels = ["습도",
                         "강수확률",
                         "풍속",
                         viewModel?.todayWeather?.sno == "적설없음" ? "강수량" : "적설량"]
    
    private lazy var weatherDatas = [viewModel?.todayWeather?.reh,
                        viewModel?.todayWeather?.pop,
                        viewModel?.todayWeather?.wsd,
                        viewModel?.todayWeather?.pcp]
    
    private lazy var weatherDatasUnits = ["%", "%", "m/s", ""]
    
    private var weatherIcon = UIImageView(frame: .zero).then {
        $0.image = UIImage(systemName: "sun.max")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFill
    }
    
    private var weatherLabel = UILabel().then {
        $0.text = "일교차"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .white
    }
    
    private var weatherValue = UILabel().then {
        $0.text = "5º"
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .white
    }
    
    
    //MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    func setValue(item: Int) {
        weatherIcon.image = UIImage(systemName: weatherIconNames[item])?.withTintColor(.white, renderingMode: .alwaysOriginal)
        weatherLabel.text = weatherLabels[item]
        weatherValue.text = (weatherDatas[item] ?? "") + weatherDatasUnits[item]
    }

    func configureUI() {
        
        [weatherIcon, weatherLabel, weatherValue].forEach { addSubview($0) }
        
        weatherIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(snp.left).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        weatherLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(20)
            make.left.equalTo(weatherIcon.snp.right).offset(20)
            make.right.equalTo(snp.right).offset(-10)
        }
        
        weatherValue.snp.makeConstraints { make in
            make.top.equalTo(weatherLabel.snp.bottom).offset(5)
            make.left.equalTo(weatherIcon.snp.right).offset(20)
            make.right.equalTo(snp.right).offset(-10)
            make.bottom.equalTo(snp.bottom).offset(-30)
        }
    }
}
