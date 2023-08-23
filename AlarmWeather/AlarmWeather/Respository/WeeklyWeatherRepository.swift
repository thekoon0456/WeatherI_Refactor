//
//  WeeklyWeatherRepository.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

import Foundation

//MARK: - 중기육상예보
//기준 0600시
//pm으로
//rnSt3Pm //3일후 강수 확률
//wf3Pm //3일후 날씨 예보

final class WeeklyWeatherRepository {

    let serviceKey = NetworkQuery.serviceKey.rawValue
    var regId = "0"
    
    lazy var weatherUrl = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst?pageNo=1%E2%80%A8&regId=\(regId)&serviceKey=\(serviceKey)&numOfRows=100&tmFc=\(DateAndTime.currentTime > "0600" ? DateAndTime.weeklyQuaryDate : DateAndTime.yesterdayweeklyQuaryDate)&dataType=JSON"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        
        getWeeklyWeatherRegId(region: LocationService.shared.administrativeArea ?? "")
        
        guard let url = URL(string: weatherUrl) else { return }
        
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
                print("WeeklyWeather JSON 파싱 성공")
                completion(.success(item))
            } else {
                self.retryRequest(completion: completion)
                completion(.failure(.parseError))
            }
        }.resume()
    }

    func parseWeatherJSON(_ api: Data) -> [WeeklyWeatherItem]? { //키 item : 값 [Item]
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeeklyWeatherEntity.self, from: api)
            let item = decodedData.response.body.items.item
            return item //[Item]
        } catch {
            print("DEBUG: WeeklyWeather JSON 파싱 실패 \(error.localizedDescription)")
            return nil
        }
    }
    
    //강원도 영동, 영서 지역 세분화되어 있음. localityRegion로 구분
    func getGangWondoEastWest(_ input: String) -> String {
        let currentLocalityRegion = LocationService.shared.localityRegion

        switch currentLocalityRegion {
        case let region where WeeklyWeatherConst.gangwonWest.contains(region ?? "철원"):
            return "강원도영서"
        case let region where WeeklyWeatherConst.gangwonEast.contains(region ?? "강릉"):
            return "강원도영동"
        default:
            return ""
        }
    }
    
    //쿼리 지역 코드
    func getWeeklyWeatherRegId(region: String) {
        switch region {
        case "서울특별시", "인천광역시", "경기도":
            regId = "11B00000"
        case let region where getGangWondoEastWest(region) == "강원도영서":
            regId = "11D10000"
        case let region where getGangWondoEastWest(region) == "강원도영동":
            regId = "11D20000"
        case "대전광역시", "세종특별자치시", "충청남도":
            regId = "11C20000"
        case "충청북도":
            regId = "11C10000"
        case "광주광역시", "전라남도":
            regId = "11F20000"
        case "전라북도":
            regId = "11F10000"
        case "대구광역시", "경상북도":
            regId = "11H10000"
        case "부산광역시", "울산광역시", "경상남도":
            regId = "11H20000"
        case "제주특별자치도":
            regId = "11G00000"
        default:
            print("DEBUG: 중기육상예보 지역 가져오기 실패")
            break
        }
    }

}

extension WeeklyWeatherRepository: RetryRequest { }
