//
//  WeeklyWeatherTempService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

final class WeeklyWeatherTempService {
    var repository = WeeklyWeatherTempRepository()
    
    func fetchWeeklyWeatherTemp(completion: @escaping ([WeeklyWeatherTempModel]) -> Void) {
        repository.performRequest { (result: Result<[WeeklyWeatherTempItem], NetworkError>) in
            switch result {
            case .success(let data):
                var weeklyWeatherTempArr = [WeeklyWeatherTempModel]()
                
                for i in 3...9 {
                    let taMinItem = "taMin\(i)"
                    let taMaxItem = "taMax\(i)"
                    let taMinValue = data[0].toDictionary?.filter { $0.key == taMinItem }.first?.value as? Int ?? 0
                    let taMaxValue = data[0].toDictionary?.filter { $0.key == taMaxItem }.first?.value as? Int ?? 0
                    
                    let model = WeeklyWeatherTempModel(
                        date: DateAndTime.getLaterDate(afterDate: i),
                        taMin: String(taMinValue),
                        taMax: String(taMaxValue),
                        diurnalRange: abs(taMinValue - taMaxValue)
                    )
                    
                    weeklyWeatherTempArr.append(model)
                }
                
                completion(weeklyWeatherTempArr)
                
            case .failure(let error):
                print("DEBUG: fetchWeeklyWeatherTempModel Error: \(error.localizedDescription)")
                break
            }
        }
    }
    
}
