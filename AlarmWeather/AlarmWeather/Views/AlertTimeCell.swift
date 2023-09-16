//
//  AlertTimeCell.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/25.
//

import UIKit

import RealmSwift

final class AlertTimeCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: SettingProfileViewModel?
    
    private var repeatDateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        $0.textColor = .white
    }
    
    private var ampmLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .white
    }
    
    private var timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        $0.textColor = .white
    }
    
    
    //MARK: - LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CellId.alertTimeCell.rawValue)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func setValue(row: Int) {
        repeatDateLabel.text = getWeeklyString(index: row)
        ampmLabel.text = getTimeString(index: row)["ampm"]
        timeLabel.text = getTimeString(index: row)["timeString"]
        configureUI()
    }
    
    func getTimeString(index: Int) -> [String : String] {
        var dic: [String : String] = [:]
//        RealmService.shared.readUsers().
        if let date = viewModel?.alertTimes?[index].time {
            let timeString = viewModel?.dateToString(date: date)
            dic.updateValue(String(timeString?.split(separator: " ").first ?? ""), forKey: "ampm")
            dic.updateValue(String(timeString?.split(separator: " ").last ?? ""), forKey: "timeString")
        }

        return dic
    }
    
    func getWeeklyString(index: Int) -> String {
        if let date = viewModel?.alertTimes?[index].weekly {
            switch date {
            case 0:
                return "매일"
            case 1:
                return "주중"
            case 2:
                return "주말"
            default:
                return ""
            }
        }
        return ""
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(repeatDateLabel)
        repeatDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
        }
        
        addSubview(ampmLabel)
        ampmLabel.snp.makeConstraints { make in
            make.left.equalTo(repeatDateLabel.snp.right).offset(90)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(ampmLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
}
