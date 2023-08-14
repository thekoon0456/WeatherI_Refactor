//
//  SaveButton.swift
//  TinderClone
//
//  Created by Deokhun KIM on 2023/05/30.
//

import UIKit

class SaveButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ColorSetting.buttonEnabledColor
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        setTitleColor(.white, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
