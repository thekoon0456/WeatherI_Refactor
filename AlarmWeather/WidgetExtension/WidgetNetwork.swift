//
//  WidgetNetwork.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/08.
//

import Combine
import SwiftUI
import Foundation

struct WeatherModel: Decodable {
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
    let sno: String //1시간 신적설 //1c
    
    private enum CoadingKeys: String, CodingKey {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoadingKeys.self)
        fcstTime = "0200"
        sky = try container.decode(String.self, forKey: .sky)
        tmp = try container.decode(String.self, forKey: .tmp)
        tmn = try container.decode(String.self, forKey: .tmn)
        tmx = try container.decode(String.self, forKey: .tmx)
        pop = try container.decode(String.self, forKey: .pop)
        pty = try container.decode(String.self, forKey: .pty)
        pcp = try container.decode(String.self, forKey: .pcp)
        reh = try container.decode(String.self, forKey: .reh)
        wsd = try container.decode(String.self, forKey: .wsd)
        sno = try container.decode(String.self, forKey: .sno)
    }
}

class WeatherNetwork {
    //todayWeather
    let serviceKey = NetworkQuery.serviceKey
    var pageCount = "500"
    //사용자 좌표구해서 쿼리 날림
    var x = UserDefaults.shared.integer(forKey: "convertedX")
    var y = UserDefaults.shared.integer(forKey: "convertedY")
    
    lazy var weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(serviceKey)&pageNo=1&numOfRows=\(pageCount)&dataType=JSON&base_date=\(DateAndTime.baseTime == "2300" ? DateAndTime.yesterdayDate : DateAndTime.todayDate)&base_time=\(DateAndTime.baseTime)&nx=\(x)&ny=\(y)"
    
    func fetchWeatherData() -> AnyPublisher<WeatherModel, Error> {
        guard let url = URL(string: weatherURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherModel.self, decoder: JSONDecoder())
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
