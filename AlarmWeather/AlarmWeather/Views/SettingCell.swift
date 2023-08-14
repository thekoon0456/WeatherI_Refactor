//
//  SettingCell.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/17.
//

import UIKit
import SnapKit
import Then

final class SettingCell: UITableViewCell {

    //MARK: - Properties
    
    var settingCellLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: settingCellId)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none //cell 선택색상 없앰
        
        contentView.addSubview(settingCellLabel)
        settingCellLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(20)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    


}
