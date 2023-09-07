//
//  DustModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

struct DustModel {
    static let defaultDustModel = DustModel(dustState: "",
                                            pm10Data: "",
                                            pm25Data: "",
                                            dustCode: "",
                                            dataTime: "")
    
    var dustState: String //"좋음"
    var pm10Data: String //68 미세먼지 농도, "seoul"
    var pm25Data: String //
    var dustCode: String //"PM10"
    var dataTime: String //2023-06-28 24:00
}
