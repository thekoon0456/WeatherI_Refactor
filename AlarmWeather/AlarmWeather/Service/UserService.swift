//
//  UserService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/27.
//

import Foundation
import RealmSwift
import UIKit


final class RealmService {
    
    static let shared = RealmService()
    
    private init() { }
    
    let realm = try! Realm()
    
    // Swift Array를 Realm의 List로 변환하는 함수
    func convertToList<T: Object>(_ array: [T]) -> List<T> {
        let list = List<T>()
        list.append(objectsIn: array)
        return list
    }

    // Realm의 List를 Swift Array로 변환하는 함수
    func convertToArray<T: Object>(_ list: List<T>) -> [T] {
        return Array(list)
    }

    //MARK: - create
    func createUser(
        userName: String?,
        alertName: String?,
        alertImage: Data?,
        alertTimes: List<AlertTimeEntity>?
    ) {
        let newUser = UserEntity()
        newUser.userName = userName
        newUser.alertName = alertName
        newUser.alertImage = alertImage // 이미지를 Data로 변환
        newUser.lastUpdated = Date()
        newUser.alertTimes.append(objectsIn: alertTimes ?? List<AlertTimeEntity>())

        try! realm.write {
            realm.add(newUser)
        }
    }
    
    //MARK: - read
    func readUsers() -> Results<UserEntity> {
        let users = realm.objects(UserEntity.self)
        return users
    }
    
    //MARK: - update
    func updateUser(
        userName: String?,
        alertName: String?,
        alertImage: Data?,
        alertTimes: List<AlertTimeEntity>?
    ) {
        let users = readUsers()
        
        if let user = users.first {
            try! realm.write {
                user.userName = userName ?? user.userName
                user.alertName = alertName ?? user.alertName
                user.alertImage = alertImage  // 이미지를 Data로 변환
                user.lastUpdated = Date()

                if let newAlertTimes = alertTimes {
                    user.alertTimes.removeAll()
                    user.alertTimes.append(objectsIn: newAlertTimes)
                }
                
            }
            
            print("DEBUG: UpdatedUser: \(user)")
        }
        
    }
    
    //MARK: - delete
    func deleteUser() {
        let users = readUsers()

        if let userToDelete = users.first {
            try! realm.write {
                realm.delete(userToDelete)
            }
        }
    }
}
