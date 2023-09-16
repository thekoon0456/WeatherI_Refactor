//
//  WidgetEntity.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/12.
//

import Foundation

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

struct Item: Codable, Equatable {
    let baseDate, baseTime, category, fcstDate: String
    let fcstTime, fcstValue: String
    let nx, ny: Int
}

struct Header: Codable {
    let resultCode, resultMsg: String
}
