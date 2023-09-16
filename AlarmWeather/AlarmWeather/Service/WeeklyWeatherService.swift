//
//  WeeklyWeatherService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/07/13.
//

import Foundation

final class WeeklyWeatherService {
    var repository = WeeklyWeatherRepository()
    
    func fetchWeeklyWeather(completion: @escaping ([WeeklyWeatherModel]) -> Void) {
        repository.performRequest { (result: Result<[WeeklyWeatherItem], NetworkError>) in
            switch result {
            case .success(let data):
                var weeklyWeatherArr = [WeeklyWeatherModel]()
                
                for i in 3...9 {
                    let rnStItem = i <= 7 ? "rnSt\(i)Pm" : "rnSt\(i)"
                    let wfItem = i <= 7 ? "wf\(i)Pm" : "wf\(i)"
                    let rnstValue = String(data[0].toDictionary?
                        .filter { $0.key == rnStItem }.first?.value as? Int ?? 0)
                    let wfValue = data[0].toDictionary?
                        .filter { $0.key == wfItem }.first?.value as? String ?? ""

                    let model = WeeklyWeatherModel(date: DateAndTime.getLaterDate(afterDate: i),
                                                   rnSt: rnstValue,
                                                   wf: wfValue)
                    weeklyWeatherArr.append(model)
                }
                
//                print("DEBUG: WeeklyWeatherModel: \(weeklyWeatherArr)")
                completion(weeklyWeatherArr)
                
            case .failure(let error):
                print("DEBUG: fetchWeeklyWeatherModel Error: \(error.localizedDescription)")
                break
            }
        }
    }

}
