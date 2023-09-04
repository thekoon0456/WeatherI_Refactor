//
//  WeeklyWeatherCell.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/24.
//

import UIKit
import SnapKit
import Then

final class WeeklyWeatherCell: UITableViewCell {

    //MARK: - Properties
    
    var viewModel: HomeViewModel?
    
    private var lineViewOffset = 0
    
    private var weeklyDate = UILabel().then {
        $0.text = "12.11" + " 월"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .white
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var weatherIcon = UIImageView().then {
        $0.image = UIImage(systemName: "cloud.drizzle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFill
    }
    
    private var probabilityLabel = UILabel().then {
        $0.text = "60"+"%"
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .white
    }
    
    private var spacingView = UIView()
    
    private var lowTemperature = UILabel().then {
        $0.text = "20"+"º"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .white
    }
    
    private var lineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private var highTemperature = UILabel().then {
        $0.text = "30"+"º"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .white
    }
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    func setValue(row: Int) {
        lineViewOffset = (50 - (viewModel?.weeklyWeatherTemp?[row].diurnalRange ?? 0) * 2)
        weeklyDate.text = viewModel?.weeklyWeatherTemp?[row].date
        lowTemperature.text = (viewModel?.weeklyWeatherTemp?[row].taMin ?? "") + "º"
        highTemperature.text = (viewModel?.weeklyWeatherTemp?[row].taMax ?? "") + "º"
        weatherIcon.image = UIImage(systemName: viewModel?.weeklyWeatherIconName[row] ?? "")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        probabilityLabel.text = (viewModel?.weeklyWeather?[row].rnSt ?? "") == "0" ? "" : (viewModel?.weeklyWeather?[row].rnSt ?? "") + "%"
        configureUI()
    }
    
    func configureUI() {
        self.frame.size.height = 80
        backgroundColor = .clear
        selectionStyle = .none
        
        [weeklyDate, weatherIcon, probabilityLabel ,lowTemperature, lineView, highTemperature].forEach { contentView.addSubview($0) }
        
        weeklyDate.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(55)
            make.left.equalTo(snp.left).offset(10)
        }
        
        weatherIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(weeklyDate.snp.right).offset(25)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
//        weatherAnimation(weatherIcon)
        
        probabilityLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherIcon.snp.bottom).offset(5)
            make.centerX.equalTo(weatherIcon.snp.centerX)
        }
        
        //일교차가 크면 줄이 길고, 작으면 줄이 짧고
        lowTemperature.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(weatherIcon.snp.right).offset(35)
        }
        
        lineView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(1.5)
            make.left.equalTo(lowTemperature.snp.right).offset(lineViewOffset).priority(1)
            make.right.equalTo(highTemperature.snp.left).offset(-lineViewOffset).priority(1)
        }
        
        highTemperature.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(snp.right).offset(-10)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
