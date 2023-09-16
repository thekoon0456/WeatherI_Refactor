//
//  SettingProfileViewModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/10.
//

import Foundation

import RealmSwift

final class SettingProfileViewModel {
    
    //MARK: - Properties
    
    var realmManager = RealmService.shared
    
    lazy var alertTimes: [AlertTimeEntity]? = realmManager.convertToArray(realmManager.readUsers().first?.alertTimes ?? List<AlertTimeEntity>()) {
        didSet {
            print("alertTimesDidSet \(String(describing: self.alertTimes))")
        }
    }
    
    func dateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "a hh:mm" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = date //발표 갱신 이전은 어제 발표로
        return dateFormatter.string(from: dateCreatedAt)
    }
}
