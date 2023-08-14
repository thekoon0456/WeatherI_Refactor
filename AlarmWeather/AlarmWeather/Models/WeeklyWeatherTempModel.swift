//
//  WeeklyWeatherTempModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

//low, high만
//기준 0600시
//taMin3 최저기온
//taMax3 최대기온

struct WeeklyWeatherTempModel {
    var date: String
    var taMin: String
    var taMax: String
    var diurnalRange: Int
}
