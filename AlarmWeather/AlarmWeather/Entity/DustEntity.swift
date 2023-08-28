//
//  DustEntity.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

// MARK: - DustEntity
struct DustEntity: Codable {
    let response: DustResponse
}

// MARK: - DustResponse
struct DustResponse: Codable {
    let body: DustBody
    let header: DustHeader
}

// MARK: - DustBody
struct DustBody: Codable {
    let totalCount: Int
    let items: [DustItem]
    let pageNo, numOfRows: Int
}

// MARK: - DustItem
struct DustItem: Codable {
    let daegu, chungnam, incheon, daejeon: String?
    let gyeongbuk, sejong, gwangju, jeonbuk: String?
    let gangwon, ulsan, jeonnam, seoul: String?
    let busan, jeju, chungbuk, gyeongnam: String?
    let dataTime, dataGubun, gyeonggi, itemCode: String?
}

// MARK: - DustHeader
struct DustHeader: Codable {
    let resultMsg, resultCode: String
}

