//
//  WeeklyWeatherTempRepository.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

//low, high만
//기준 0600시
//taMin3 최저기온
//taMax3 최대기온

final class WeeklyWeatherTempRepository {

    let serviceKey = NetworkQuery.serviceKey
    lazy var regId = getWeeklyWeatherTempRegId(currentAdministrativeArea: LocationService.shared.administrativeArea ?? "", currentLocality: LocationService.shared.localityRegion ?? "")
    
    lazy var weatherUrl = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa?serviceKey=\(serviceKey)&pageNo=1&numOfRows=1000&dataType=JSON&regId=\(regId)&tmFc=\(DateAndTime.currentTime >= "0600" ? DateAndTime.weeklyQuaryDate : DateAndTime.yesterdayweeklyQuaryDate)"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {

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
                print("WeeklyWeatherTemp JSON 파싱 성공")
                completion(.success(item))
            } else {
                self.retryRequest(completion: completion)
                completion(.failure(.parseError))
            }
        }.resume()
    }
    
    func parseWeatherJSON(_ api: Data) -> [WeeklyWeatherTempItem]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeeklyWeatherTempEntity.self, from: api)
            let item = decodedData.response.body.items.item
            return item
        } catch {
            print("DEBUG: WeeklyWeatherTemp JSON 파싱 실패 \(error.localizedDescription)")
            return nil
        }
    }
    
    //쿼리 지역 코드
    func getWeeklyWeatherTempRegId(currentAdministrativeArea: String, currentLocality: String) -> String {
        let region = WeeklyWeatherConst.weeklyTempDic.filter { dic in
            let userRegion = dic.key.split(separator: " ") //경기도, 수원
            return userRegion[0].contains(currentAdministrativeArea) && currentLocality.contains(userRegion[1])
        }.first?.value
        
        //혹시 지역코드가 없으면 같은 시, 도 지역코드를 가져옴
        let notContainsRegion = WeeklyWeatherConst.weeklyTempDic.filter { dic in
            let userRegion = dic.key.split(separator: " ")
            return userRegion[0].contains(currentAdministrativeArea)
        }.first?.value
        
        //MARK: - 언래핑 실패시 11B10101 서울코드로
        print("DEBUG: WeatherTempRegId \(String(describing: region))")
        return region ?? notContainsRegion ?? "11B10101" //nil이면 서울시 지역 코드 사용
    }

}

extension WeeklyWeatherTempRepository: RetryRequest { }
