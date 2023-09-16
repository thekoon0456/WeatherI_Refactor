//
//  TextFieldViewModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/26.
//

import Foundation

struct TextFieldViewModel {
    
    //MARK: - Properties
    
    var userName: String? = RealmService.shared.readUsers().first?.userName
    var alertName: String? = RealmService.shared.readUsers().first?.alertName
    
    var formIsValid: Bool {
        return userName?.first != " " && alertName?.first != " "
    }
}
