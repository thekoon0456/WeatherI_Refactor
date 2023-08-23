//
//  WeatherService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/20.
//

import Foundation

//최대 4일치 데이터 들어옴
//패치 등 로직
final class WeatherService {
    let repository = WeatherRepository()
    
    func fetchTodayWeather(completion: @escaping (WeatherModel) -> Void) {
        repository.performRequest { (result: Result<[Item], NetworkError>) in
            switch result {
            case .success(let data):
                let model = WeatherModel(fcstTime: data.filter { $0.fcstTime == DateAndTime.currentTime }.first?.fcstTime ?? "",
                                         sky: data.filter{ $0.fcstDate == DateAndTime.todayDate && $0.category == Category.sky }.first?.fcstValue ?? "",
                                         tmp: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.tmp }.first?.fcstValue ?? "",
                                         tmn: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.tmn }.first?.fcstValue ?? "",
                                         tmx: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.tmx }.first?.fcstValue ?? "",
                                         pop: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.pop }.first?.fcstValue ?? "",
                                         pty: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.pty }.first?.fcstValue ?? "",
                                         pcp: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.pcp }.first?.fcstValue ?? "",
                                         reh: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.reh }.first?.fcstValue ?? "",
                                         wsd: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.wsd }.first?.fcstValue ?? "",
                                         sno: data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == Category.sno }.first?.fcstValue ?? "")
                print("DEBUG: todayModel: \(model)")
                completion(model)
                
            case .failure(let error):
                print("DEBUG: fetchtodayModel Error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    func fetchTodayDetailWeather(completion: @escaping (([TodayDetailWeatherModel], [TodayDetailWeatherModel])) -> Void) {
        //MARK: - 2시간 간격 3일. 메인
        repository.performRequest { (result: Result<[Item], NetworkError>) in
            switch result {
            case .success(let data):
                var completedModel = [TodayDetailWeatherModel]()
                var timeArr = [String]()
                
                for i in 0..<WeatherModelCount.todayDetailWeatherCount.rawValue {
                    let time: String = {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "ko_kr")
                        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                        dateFormatter.dateFormat = "HH00" //0500
                        let timeInterval = Double((i + 1) * 2 * 60 * 60) //cell에 나오는 데이터들의 시간 간격 설정 가능
                        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + timeInterval)
                        return dateFormatter.string(from: dateCreatedAt)
                    }()
                    timeArr.append(time)
                }
                
                print("DEBUG: fcstTime: \(timeArr)")
                
                for i in 0..<WeatherModelCount.todayDetailWeatherCount.rawValue {
                    //받오는 시간 중간에 ":" 넣어줌
                    var fcstTime = timeArr[i]
                    let fcstTimeIndex = fcstTime.startIndex
                    let insertIndex = fcstTime.index(fcstTimeIndex, offsetBy: 2)
                    fcstTime.insert(":", at: insertIndex)
                    
                    let model = TodayDetailWeatherModel(fcstDate: DateAndTime.getfcstDate(afterTime: (i + 1) * 2),
                                                        fcstTime: fcstTime,
                                                        sky: data.filter { $0.fcstTime == timeArr[i] && $0.category == Category.sky }.first?.fcstValue ?? "",
                                                        pty: data.filter { $0.fcstTime == timeArr[i] && $0.category == Category.pty }.first?.fcstValue ?? "",
                                                        pop: (data.filter { $0.fcstTime == timeArr[i] && $0.category == Category.pop }.first?.fcstValue ?? ""),
                                                        tmp: (data.filter { $0.fcstTime == timeArr[i] && $0.category == Category.tmp }.first?.fcstValue ?? ""))
                    completedModel.append(model)
                }
                
                //MARK: - 1시간 간격 추가
                var oneHourCompletedModel = [TodayDetailWeatherModel]()
                var oneHourTimeArr = [String]()
                
                for i in 0..<WeatherModelCount.todayOneHourWeatherCount.rawValue {
                    let time: String = {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "ko_kr")
                        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                        dateFormatter.dateFormat = "HH00" //0500
                        let timeInterval = Double((i + 1) * 60 * 60) //cell에 나오는 데이터들의 시간 간격 설정 가능
                        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + timeInterval)
                        return dateFormatter.string(from: dateCreatedAt)
                    }()
                    oneHourTimeArr.append(time)
                }
                
                print("DEBUG: fcstTime: \(oneHourTimeArr)")
                
                for i in 0..<WeatherModelCount.todayOneHourWeatherCount.rawValue {
                    //받오는 시간 중간에 ":" 넣어줌
                    var fcstTime = oneHourTimeArr[i]
                    let fcstTimeIndex = fcstTime.startIndex
                    let insertIndex = fcstTime.index(fcstTimeIndex, offsetBy: 2)
                    fcstTime.insert(":", at: insertIndex)
                    
                    let model = TodayDetailWeatherModel(fcstDate: DateAndTime.getfcstDate(afterTime: i + 1),
                                                        fcstTime: fcstTime,
                                                        sky: data.filter { $0.fcstTime == oneHourTimeArr[i] && $0.category == Category.sky }.first?.fcstValue ?? "",
                                                        pty: data.filter { $0.fcstTime == oneHourTimeArr[i] && $0.category == Category.pty }.first?.fcstValue ?? "",
                                                        pop: (data.filter { $0.fcstTime == oneHourTimeArr[i] && $0.category == Category.pop }.first?.fcstValue ?? ""),
                                                        tmp: (data.filter { $0.fcstTime == oneHourTimeArr[i] && $0.category == Category.tmp }.first?.fcstValue ?? ""))
                    oneHourCompletedModel.append(model)
                }
                
                print("DEBUG: todayDetailModel: \(completedModel)")
                completion((completedModel, oneHourCompletedModel))
                
//                completion(completedModel) //기존 completion
            case .failure(let error):
                print("DEBUG: fetchtodayDetailModel Error: \(error.localizedDescription)")
                break
            }
        }
    }
}
