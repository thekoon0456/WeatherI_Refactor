//
//  WeatherEntity.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

//서버에서 오는 원천 데이터
struct WeatherEntity: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct Body: Codable {
    let dataType: String
    let items: Items
    let pageNo, numOfRows, totalCount: Int
}

struct Items: Codable {
    let item: [Item]
}

struct Item: Codable {
    let baseDate, baseTime: String?
    let category: Category?
    let fcstDate, fcstTime, fcstValue: String?
    let nx, ny: Int?
}

enum Category: String, Codable {
    case pcp = "PCP"
    case pop = "POP"
    case pty = "PTY"
    case reh = "REH"
    case sky = "SKY"
    case sno = "SNO"
    case tmn = "TMN"
    case tmp = "TMP"
    case tmx = "TMX"
    case uuu = "UUU"
    case vec = "VEC"
    case vvv = "VVV"
    case wav = "WAV"
    case wsd = "WSD"
}

struct Header: Codable {
    let resultCode, resultMsg: String
}
