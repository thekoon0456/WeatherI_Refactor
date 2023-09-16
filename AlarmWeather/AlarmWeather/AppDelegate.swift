//
//  AppDelegate.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//
import CoreData
import CoreLocation
import UIKit
import WidgetKit

import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        // 위젯 업데이트 요청 보내기
//        WidgetCenter.shared.reloadTimelines(ofKind: "com.thekoon.NotiWeather.WidgetExtension")
        
        //MARK: - Realm 마이그레이션
        
        let defaultRealm = Realm.Configuration.defaultConfiguration.fileURL!
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.weatherI.widget")
        let realmURL = container?.appendingPathComponent("default.realm")
        var config: Realm.Configuration!

        // Checking the old realm config is exist
        if FileManager.default.fileExists(atPath: defaultRealm.path) {
            do {
                _ = try FileManager.default.replaceItemAt(realmURL!, withItemAt: defaultRealm)
               config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
            } catch {
               print("Error info: \(error)")
            }
        } else {
             config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        }

        Realm.Configuration.defaultConfiguration = config

        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
        

}
