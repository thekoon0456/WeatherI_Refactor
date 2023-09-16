//
//  DustEntity.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

struct DustEntity: Codable {
    let response: DustResponse
}

struct DustResponse: Codable {
    let body: DustBody
    let header: DustHeader
}

struct DustBody: Codable {
    let totalCount: Int
    let items: [DustItem]
    let pageNo, numOfRows: Int
}

struct DustItem: Codable {
    let daegu, chungnam, incheon, daejeon: String?
    let gyeongbuk, sejong, gwangju, jeonbuk: String?
    let gangwon, ulsan, jeonnam, seoul: String?
    let busan, jeju, chungbuk, gyeongnam: String?
    let dataTime, dataGubun, gyeonggi, itemCode: String?
}

struct DustHeader: Codable {
    let resultMsg, resultCode: String
}

