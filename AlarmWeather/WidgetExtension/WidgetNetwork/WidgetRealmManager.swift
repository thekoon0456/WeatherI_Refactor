//
//  WidgetRealmManager.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/14.
//

import Foundation

import RealmSwift

class WidgetRealmManager {
    
    //MARK: - Properties
    
    static let shared = WidgetRealmManager()
    
    private var localRealm: Realm {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.weatherI.widget")
        let realmURL = container?.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        return try! Realm(configuration: config)
    }
    
    private init() { }
    
    func readUsers() -> Results<UserEntity> {
        let users = localRealm.objects(UserEntity.self)
        return users
    }
}

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
