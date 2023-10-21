//
//  DustRepository.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

final class DustRepository {
    
    //MARK: - Properties
    
    let serviceKey = NetworkQuery.serviceKey
    var itemCount = "1"
    var itemCode = "PM10" //"PM25"
    var dataGubun = "HOUR"

    lazy var dustURL = "http://apis.data.go.kr/B552584/ArpltnStatsSvc/getCtprvnMesureLIst?itemCode=\(itemCode)&dataGubun=\(dataGubun)&pageNo=1&numOfRows=\(itemCount)&returnType=json&serviceKey=\(serviceKey)"
    
    func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
        guard let url = URL(string: dustURL) else { return }
        
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

            if let item = parseDustJSON(data) as? [T] {
                print("Dust JSON 파싱 성공")
                completion(.success(item))
            } else {
                retryRequest(completion: completion)
                completion(.failure(.parseError))
            }
        }.resume()
    }

    func parseDustJSON(_ api: Data) -> [DustItem]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DustEntity.self, from: api)
            let item = decodedData.response.body.items //[DustItem]
            return item
        } catch {
            print("Dust JSON 파싱 실패 \(error.localizedDescription)")
            return nil
        }
    }
}

extension DustRepository: RetryRequest {}
