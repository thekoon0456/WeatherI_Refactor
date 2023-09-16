//
//  AlertService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/25.
//

import UIKit
import UserNotifications

import RealmSwift

final class AlertService {
    
    //MARK: - properties
    
    static let shared = AlertService()
    
    // UNUserNotificationCenter 객체 생성
    let center = UNUserNotificationCenter.current()
    let realmManager = RealmService.shared
    
    //바뀔때마다 트리거 추가
    lazy var userAlertTimes: [AlertTimeEntity]? = realmManager.convertToArray(realmManager.readUsers().first?.alertTimes ?? List<AlertTimeEntity>()) {
        didSet {
            print("DEBUG: Alert 추가됨 \(String(describing: self.userAlertTimes))")
            settingTriggers { triggers in
                self.sendNotification(triggers: triggers)
            }
        }
    }
    
    private init() { }
  
    func settingTriggers(completion: @escaping ([UNCalendarNotificationTrigger]) -> Void) {
        // 기존 트리거 삭제
        center.removeAllPendingNotificationRequests()
        
        //트리거 초기화 후 현재 추가한 [AlertTimeEntity]만 넣기
        var triggers: [UNCalendarNotificationTrigger] = []
        
        guard let dateArray = userAlertTimes else { return }
        
        for i in 0..<dateArray.count {
            // Date를 DateComponents로 변환
            var dateComponents = DateComponents()
            // DateComponents를 통해 UNCalendarNotificationTrigger 생성
            var trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            switch dateArray[i].weekly {
            case 0:
                dateComponents.hour = (getTimeString(index: i)["hour"]! + getTimeString(index: i)["ampm"]!)
                dateComponents.minute = getTimeString(index: i)["minute"] ?? 0
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                triggers.append(trigger)
                print("DEBUG: settingTriggers \(triggers) 추가됨")
            case 1:
                var dateComponents = DateComponents()
                for j in 2...6 {
                    dateComponents.weekday = j
                    dateComponents.hour = (getTimeString(index: i)["hour"]! + getTimeString(index: i)["ampm"]!)
                    dateComponents.minute = getTimeString(index: i)["minute"] ?? 0
                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    triggers.append(trigger)
                    print("DEBUG: settingTriggers \(triggers) 추가됨")
                }
            case 2:
                var dateComponents = DateComponents()
                for k in [1,7] {
                    dateComponents.weekday = k //일,토
                    dateComponents.hour = (getTimeString(index: i)["hour"]! + getTimeString(index: i)["ampm"]!)
                    dateComponents.minute = getTimeString(index: i)["minute"] ?? 0
                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    triggers.append(trigger)
                    print("DEBUG: settingTriggers \(triggers) 추가됨")
                }
            default:
                break
            }
        }
        
        print("DEBUG: 저장된 트리거: \(triggers)")
        completion(triggers)
    }
    
    func sendNotification(triggers: [UNCalendarNotificationTrigger]) {

        for (index, trigger) in triggers.enumerated() {
            let content = UNMutableNotificationContent() // 로컬알림에 대한 속성 설정
            print("DEBUG: triggerDate: \(trigger.dateComponents)")
            
            //ContentsExtension 사용
            let customUICategory = UNNotificationCategory(identifier: CategoryIdentifier.cumstomUI,
                                                          actions: [],
                                                          intentIdentifiers: [])
            center.setNotificationCategories([customUICategory])
            
            var userInfo: [String: Any] = [:]
            userInfo["alertName"] = realmManager.readUsers().first?.alertName
            
            content.title = "날씨의 i ☀️"
            content.subtitle = realmManager.readUsers().first?.alertName != nil ? "날씨요정 \(realmManager.readUsers().first?.alertName ?? "")님이 도착했어요" : "오늘의 날씨가 도착했어요"
            content.body = "꾹 눌러서 날씨를 확인해주세요👆"
            content.sound = .default
            content.userInfo = userInfo
            content.categoryIdentifier = CategoryIdentifier.cumstomUI  //ContentsExtension
            
            let request = UNNotificationRequest(identifier: "notification_\(index)", content: content, trigger: trigger)
            
            center.add(request) { (error) in
                if let error = error {
                    print("알림 요청 실패: \(error.localizedDescription)")
                } else {
                    print("알림 요청 성공")
                }
            }
            
        }
    }

    //앱 켤때 처음 권한 요청
    func setAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
    }
    
    func getTimeString(index: Int) -> [String : Int] {
        var dic: [String : Int] = [:]
        if let date = realmManager.readUsers().first?.alertTimes[index].time {
            let timeString = dateToString(date: date)
            let arr = timeString.split(separator: ":")

            if arr[0] == "오후" && arr[1] == "12" { //오후 12시는 12 안더함
                dic.updateValue(0, forKey: "ampm")
            } else if arr[0] == "오전" && arr[1] == "12" { //오전12시는 12뺌
                dic.updateValue(-12, forKey: "ampm")
            } else {
                dic.updateValue(Int(arr[0] == "오전" ? 0 : 12), forKey: "ampm") // 오후면 12 더함
            }
            dic.updateValue(Int(arr[1]) ?? 0, forKey: "hour")
            dic.updateValue(Int(arr[2]) ?? 0, forKey: "minute")
        }
        
        return dic
    }
    
    func dateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "a:hh:mm"
        let dateCreatedAt = date
        return dateFormatter.string(from: dateCreatedAt)
    }
    
}
