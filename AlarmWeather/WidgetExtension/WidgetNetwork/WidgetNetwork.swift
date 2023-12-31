//
//  WidgetNetwork.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/08.
//

import Foundation

class WeatherNetwork: RetryRequest {
    
    //MARK: - Properties
    
    let serviceKey = NetworkQuery.serviceKey
    var pageCount = "500"

    //사용자 좌표구해서 쿼리 날림
    //integer는 옵셔널이 아니고, 0을 기본값으로 반환. 옵셔널 쓰려면 .object사용 / string은 옵셔널 반환
    //본 앱에서 쿼리좌표 가져오는 구조라 처음 깔자마자 위젯먼저 설치하는경우, 서울좌표로 띄우고, 앱을 접속해달라는 안내 함
    var x: Int? = UserDefaults.shared.object(forKey: "convertedX") as? Int
    var y: Int? = UserDefaults.shared.object(forKey: "convertedY") as? Int

    lazy var weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(serviceKey)&pageNo=1&numOfRows=\(pageCount)&dataType=JSON&base_date=\(DateAndTime.baseTime == "2300" ? DateAndTime.yesterdayDate : DateAndTime.todayDate)&base_time=\(DateAndTime.baseTime)&nx=\(x ?? 60)&ny=\(y ?? 127)"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        guard let url = URL(string: weatherURL) else { return }

        let session = setCustomURLSession(retryRequest: DoubleConstant.networkRequest.rawValue)
        session.dataTask(with: url) { data, response, error in
            if error != nil {
                print("네트워크 에러 \(String(describing: error?.localizedDescription))")
                completion(.failure(.networkingError))
                self.retryRequest(completion: completion)
                return
            }
            
            guard let data = data else {
                print("데이터 에러")
                completion(.failure(.dataError))
                self.retryRequest(completion: completion)
                return
            }

            if let item = self.parseWeatherJSON(data) as? [T] {
                print("Weather JSON 파싱 성공")
                completion(.success(item))
            } else {
                self.retryRequest(completion: completion)
                completion(.failure(.parseError))
            }
        }.resume()
    }
    
    func parseWeatherJSON(_ api: Data) -> [Item]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherEntity.self, from: api)
            let item = decodedData.response.body.items.item
            return item //[Item]
        } catch {
            print("DEBUG: Weather JSON 파싱 실패 \(error.localizedDescription)")
            return nil
        }
    }
}

class DustNetwork {
    //todayDust
    let serviceKey = NetworkQuery.serviceKey
    var itemCount = "1"
    var itemCode = "PM10" //"PM25"
    var dataGubun = "HOUR"
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? ""
    
    lazy var dustURL = "http://apis.data.go.kr/B552584/ArpltnStatsSvc/getCtprvnMesureLIst?itemCode=\(itemCode)&dataGubun=\(dataGubun)&pageNo=1&numOfRows=\(itemCount)&returnType=json&serviceKey=\(serviceKey)"
    
    lazy var userRegion: String = getDustRegion(region: administrativeArea)
    
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
