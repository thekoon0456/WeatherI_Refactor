//
//  DustViewModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/27.
//

import UIKit

final class DustViewModel {
    
    //MARK: - Properties
    
    let dustService = DustService()
    var todayDust: DustModel? //홈에서 사용하는 오늘날씨 데이터
    var todayDustIconName = "" //홈 메인 아이콘
    var todayDustMainMent = "" //홈 메인 멘트
    var todayDustMentColor = UIColor.white

    //서비스의 fetchNow -> 뷰모델 데이터로 변환
    func loadTodayDust(completion: @escaping (DustModel) -> Void) {
        dustService.fetchDustWeather { [weak self] model in
            guard let self = self else { return }
            todayDust = model
            todayDustIconName = setDustMainIcon(model: model)
            todayDustMainMent = setDustMainMent(model: model)
            todayDustMentColor = setDustMentColor(model: model)
            completion(self.todayDust ?? model)
        }
    }
    
    func setDustMainIcon(model: DustModel) -> String {
        switch model.dustState {
        case "좋음":
            return "aqi.low"
        case "보통":
            return "aqi.medium"
        case "나쁨", "매우 나쁨":
            return "aqi.high"
        default:
            return ""
        }
    }
    
    func setDustMentColor(model: DustModel) -> UIColor {
        switch model.dustState {
        case "좋음":
            return UIColor.systemGreen
        case "보통":
            return UIColor.white
        case "나쁨", "매우 나쁨":
            return UIColor.systemRed
        default:
            return UIColor.white
        }
    }
    
    func setDustMainMent(model: DustModel) -> String {
        switch model.dustState {
        case "좋음":
            return "미세먼지 상태가 좋습니다 😆"
        case "보통":
            return "미세먼지 상태가 보통입니다 😊"
        case "나쁨", "매우 나쁨":
            return "미세먼지 상태가 나쁩니다. 마스크를 챙겨주세요! 😷"
        default:
            return ""
        }
    }
    
}
