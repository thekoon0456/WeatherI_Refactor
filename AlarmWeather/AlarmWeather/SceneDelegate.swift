//
//  SceneDelegate.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let rootVc = RootViewController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: rootVc)
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 위젯 업데이트 요청 보내기
        WidgetCenter.shared.reloadTimelines(ofKind: "com.thekoon.NotiWeather.WidgetExtension")
        
        // 앱 종료시 임시파일 삭제
        deleteFilesInTmpDirectory()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
}

extension SceneDelegate {
    //앱 종료시 임시파일 삭제 메서드
    func deleteFilesInTmpDirectory() {
        let fileManager = FileManager.default
        let tmpDirectory = NSTemporaryDirectory()
        
        do {
            let tmpContents = try fileManager.contentsOfDirectory(atPath: tmpDirectory)
            for file in tmpContents {
                let filePath = (tmpDirectory as NSString).appendingPathComponent(file)
                try fileManager.removeItem(atPath: filePath)
                print("삭제된 임시 파일: \(filePath)")
            }
        } catch {
            print("DEBUG: TMP 폴더 삭제 Error - \(error.localizedDescription)")
        }
    }
}

