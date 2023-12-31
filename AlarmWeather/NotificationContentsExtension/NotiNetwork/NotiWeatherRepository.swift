//
//  WeatherRepository.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

final class WeatherRepository {
    
    //MARK: - Properties
    
    let serviceKey = NetworkQuery.serviceKey
    var pageCount = "300"
    //사용자 좌표구해서 쿼리 날림
    var x: Int? = UserDefaults.shared.object(forKey: "convertedX") as? Int
    var y: Int? = UserDefaults.shared.object(forKey: "convertedY") as? Int
    
    lazy var weatherURL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(serviceKey)&pageNo=1&numOfRows=300&dataType=JSON&base_date=\(DateAndTime.baseTime == "2300" ? DateAndTime.yesterdayDate : DateAndTime.todayDate)&base_time=\(DateAndTime.baseTime)&nx=\(x ?? 60)&ny=\(y ?? 127)"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        guard let url = URL(string: weatherURL) else { return }

        let session = setCustomURLSession(retryRequest: DoubleConstant.networkRequest.rawValue)
        session.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            if error != nil {
                print("네트워크 에러 \(String(describing: error?.localizedDescription))")
                completion(.failure(.networkingError))
                retryRequest(completion: completion)
                return
            }

            guard let data = data else {
                print("데이터 에러")
                completion(.failure(.dataError))
                retryRequest(completion: completion)
                return
            }

            if let item = self.parseWeatherJSON(data) as? [T] {
                print("Weather JSON 파싱 성공")
                completion(.success(item))
            } else {
                retryRequest(completion: completion)
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
