//
//  WeeklyWeatherModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

//기준 0600시
//pm으로
//rnSt3Pm //3일후 강수 확률
//wf3Pm //3일후 날씨 예보

struct WeeklyWeatherModel {
    var date: String
    var rnSt: String
    var wf: String
}
