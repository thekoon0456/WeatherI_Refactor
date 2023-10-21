//
//  Weather.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import Foundation

//엔티티로부터 필요한것만 꺼내온 모델
//서비스 로직에 사용됨

//단기예보 카테고리

struct WeatherModel: Codable {
    //날씨, 온도
    var fcstTime: String //예보시각 //0500
    var sky: String //하늘 상태 //코드값
    let tmp: String //1시간 기온 //c
    let tmn: String //일 최저 기온 //c
    let tmx: String //일 최고 기온 //c
    
    //비
    let pop: String //강수 확률 %
    var pty: String //강수 형태 //코드값
    let pcp: String //1시간 강수량 //1mm
    
    //습도, 풍속
    let reh: String //습도 //%
    let wsd: String //풍속 //m/s
    
    //눈
    let sno: String //1시간 신적설 //1cm
}

struct TodayDetailWeatherModel: Equatable {
    var fcstDate: String
    var fcstTime: String //예보시각 //0500
    var sky: String //하늘 상태 //코드값
    var pty: String //강수 형태 //코드값
    var pop: String //강수 확률 %
    let tmp: String //1시간 기온 //c
}

struct TodayDetailWeather {
    //3시간 단위, 8개
    let todayDetailWeather: String //아이콘 연동
    let todayDetailTime: String
    let todayDetailTemp: String
}

