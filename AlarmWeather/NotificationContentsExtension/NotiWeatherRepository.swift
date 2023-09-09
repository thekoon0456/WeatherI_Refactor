//
//  WeatherRepository.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

final class WeatherRepository {
    
    let serviceKey = NetworkQuery.serviceKey
    var pageCount = "300"
    //사용자 좌표구해서 쿼리 날림
    var nx = "0"
    var ny = "0"
    
    lazy var weatherUrl = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(serviceKey)&pageNo=1&numOfRows=300&dataType=JSON&base_date=\(DateAndTime.baseTime == "2300" ? DateAndTime.yesterdayDate : DateAndTime.todayDate)&base_time=\(DateAndTime.baseTime)&nx=\(nx)&ny=\(ny)"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        nx = String(LocationDataService.x)
        ny = String(LocationDataService.y)
        
        print("nx: \(nx), ny: \(ny)")

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
                print("Weather JSON 파싱 성공")
                completion(.success(item))
            } else {
                self.retryRequest(completion: completion)
                completion(.failure(.parseError))
            }
        }.resume()
    }

    func parseWeatherJSON(_ api: Data) -> [Item]? { //키 item : 값 [Item]
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

extension WeatherRepository: RetryRequest { }
