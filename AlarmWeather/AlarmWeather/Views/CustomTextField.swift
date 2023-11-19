//
//  CustomTextField.swift
//  TinderClone
//
//  Created by Deokhun KIM on 2023/05/30.
//

import UIKit

import SnapKit
import Then

class CustomTextField: UITextField {
    
    init(placeHolder: String, isSecureTextEntry: Bool? = false) {
        super.init(frame: .zero)
        self.delegate = self
        
        let spacer = UIView(frame: self.bounds)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(12)
        }
        
        spacer.frame = frame
        leftView = spacer
        leftViewMode = .always
        
        keyboardAppearance = .dark
        
        borderStyle = .none
        textColor = .white
        backgroundColor = UIColor(white: 1, alpha: 0.2)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        layer.cornerRadius = 5
        attributedPlaceholder = NSAttributedString(string: placeHolder,
                                                   attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        self.isSecureTextEntry = isSecureTextEntry ?? false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension CustomTextField: UITextFieldDelegate {
    //입력 제한
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let maxLength = 10 //최대 10글자
        
        return newText.count <= maxLength
    }
    
    //엔터 눌렀을때 dismiss
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
