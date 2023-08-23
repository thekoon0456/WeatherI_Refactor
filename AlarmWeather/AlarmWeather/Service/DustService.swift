//
//  DustService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

final class DustService {
    var repository = DustRepository()

    func fetchDustWeather(completion: @escaping (DustModel) -> Void) {
        
        let userRegion: String = getDustRegion(region: LocationService.shared.administrativeArea ?? "")
        
        print("DEBUG: DustUserRegion: \(userRegion)")
        
        repository.performRequest { (result: Result<[DustItem], NetworkError>) in
            switch result {
            case .success(let data):
                let dicValue = data[0].toDictionary?.filter { $0.key == userRegion }.first?.value as? String ?? ""
                print("DEBUG: DustData: \(dicValue)")
                let model = DustModel(dustState: self.dustPm10DataToString(dustData: dicValue),
                                      pm10Data: dicValue,
                                      pm25Data: "PM10 사용중",
                                      dustCode: data[0].itemCode,
                                      dataTime: data[0].dataTime)
                
                print("DEBUG: DustModel: \(model)")
                completion(model)
                
            case .failure:
                print("Dust 모델 넣기 실패")
                break
            }
        }
    }
    
    func dustPm10DataToString(dustData: String) -> String {
        let intDuatData = Int(dustData) ?? 0
        switch intDuatData {
        case let i where 0 <= i && i <= 30:
            return "좋음"
        case let i where 31 <= i && i <= 80:
            return "보통"
        case let i where 81 <= i && i <= 150:
            return "나쁨"
        case let i where 150 <= i:
            return "매우 나쁨"
        default:
            return ""
        }
    }
    
    func dustPm25DataToString(dustData: String) -> String {
        let intDuatData = Int(dustData) ?? 0
        switch intDuatData {
        case let i where 0 <= i && i <= 15:
            return "좋음"
        case let i where 16 <= i && i <= 35:
            return "보통"
        case let i where 36 <= i && i <= 75:
            return "나쁨"
        case let i where 76 <= i:
            return "매우 나쁨"
        default:
            return ""
        }
    }
    
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
        default:
            return "서울특별시"
        }
    }
    
}

