//
//  WidgetNetwork.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/08.
//

import Combine
import SwiftUI

class WeatherNetwork {
    //todayWeather
    let serviceKey = NetworkQuery.serviceKey
    var pageCount = "20"
    //사용자 좌표구해서 쿼리 날림
    var x: Int? = UserDefaults.shared.object(forKey: "convertedX") as? Int
    var y: Int? = UserDefaults.shared.object(forKey: "convertedY") as? Int
    
    lazy var weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(serviceKey)&pageNo=1&numOfRows=\(pageCount)&dataType=JSON&base_date=\(DateAndTime.baseTime == "2300" ? DateAndTime.yesterdayDate : DateAndTime.todayDate)&base_time=\(DateAndTime.baseTime)&nx=\(x ?? 60)&ny=\(y ?? 127)"
    
     //Fetch data from the network
    func fetchWeatherData() -> AnyPublisher<WeatherEntity, Error> {
        guard let url = URL(string: weatherURL) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
//            .print()
            .decode(type: WeatherEntity.self, decoder: JSONDecoder())
            .mapError { error in
                // decode 연산자 이후에 발생한 오류 처리
                print("Decode error: \(error)")
                return error
            }
            .retry(5) // 디코딩 이후 발생한 오류에 대한 재시도
            .eraseToAnyPublisher()
    }
}

class DustNetwork {
    //todayDust
    let serviceKey = NetworkQuery.serviceKey
    var itemCount = "1"
    var itemCode = "PM10" //"PM25"
    var dataGubun = "HOUR"
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? ""

    lazy var dustUrl = "http://apis.data.go.kr/B552584/ArpltnStatsSvc/getCtprvnMesureLIst?itemCode=\(itemCode)&dataGubun=\(dataGubun)&pageNo=1&numOfRows=\(itemCount)&returnType=json&serviceKey=\(serviceKey)"
    
    lazy var userRegion: String = getDustRegion(region: administrativeArea)
//
    func getDustRegion(region: String) -> String {
        switch region {
        case "서울특별시":
            return "seoul"
        case "부산광역시":
            return "busan"
        case "대구광역시":
            return "daegu"
        case "인천광역시":
            return "incheon"
        case "광주광역시":
            return "gwangju"
        case "대전광역시":
            return "daejeon"
        case "울산광역시":
            return "ulsan"
        case "세종특별자치시":
            return "sejong"
        case "경기도":
            return "gyeonggi"
        case "강원도":
            return "gangwon"
        case "충청북도":
            return "chungbuk"
        case "충청남도":
            return "chungnam"
        case "전라북도":
            return "jeonbuk"
        case "전라남도":
            return "jeonnam"
        case "경상북도":
            return "gyeongbuk"
        case "경상남도":
            return "gyeongnam"
        case "제주특별자치도":
            return "jeju"
        case "제주도":
            return "jeju"
        default:
            return "서울특별시"
        }
    }
}
