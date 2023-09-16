//
//  UserEntity.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/27.
//

import Foundation

import RealmSwift

class UserEntity: Object {
    @Persisted var userName: String?
    @Persisted var alertName: String?
    @Persisted var alertImage: Data?
    @Persisted var alertTimes: List<AlertTimeEntity>
    @Persisted var lastUpdated: Date?
}

class AlertTimeEntity: Object {
    @Persisted var time: Date?
    @Persisted var weekly: Int?
}
