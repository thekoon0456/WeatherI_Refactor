//
//  HomeViewModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/11.
//

import CoreLocation
import UIKit

import Then

final class HomeViewModel {
    
    //MARK: - Properties
    
    let weatherService = WeatherService()
    
    var todayWeather: WeatherModel? //홈에서 사용하는 오늘 날씨 데이터
    var todayWeatherMainMent = "" //홈 메인 멘트
    var todayWeatherIconName = "sun.max.trianglebadge.exclamationmark" //홈 메인 아이콘, 오류시 느낌표
    var todayWeatherLabel = "" //홈 메인 아이콘 아래 날씨
    var todayRainyWeatherMent = ""
    var todayBackgroundImage = BackGroundImage.rainyNight[3] //배경화면 사진 //배경화면 사진
    var todayRecommendItems: [String] = [] //추천 아이템
    var todayDetailWeather: [TodayDetailWeatherModel]? //컬렉션뷰에서 사용하는 데이터
    var todayDetailWeatherIconName: [String] = [] //todayDetailIcon
    var administrativeArea: String? = UserDefaults.shared.string(forKey: "administrativeArea") ?? "위치 인식 실패"
    var weeklyWeatherIconName: [String] = []
    
    //서비스의 fetchNow -> 뷰모델 데이터로 변환
    func loadTodayWeather(completion: @escaping (WeatherModel) -> Void) {
        weatherService.fetchTodayWeather { [weak self] model in
            guard let self = self else { return }
            todayWeather = model
            todayWeatherMainMent = todayWeatherMent(model: model)
            getHomeViewBackgroundImage(model: model)
            print("DEBUG: TodayBGImage: \(todayBackgroundImage)")
            print("DEBUG: TodayWeatherModel: \(String(describing: self.todayWeather))")
            completion(todayWeather ?? model)
        }
    }
    
    func loadTodayDetailWeather(completion: @escaping ([TodayDetailWeatherModel]) -> Void) {
        weatherService.fetchTodayDetailWeather { [weak self] model in
            guard let self = self else { return }
            todayDetailWeather = model
            todayDetailWeatherIcon(model: model)
            getRainyMent(model: model)
            todayRecommendItems = getTodayRecommendItems(model: model)
//            print("DEBUG: detailWeatherIconArr: \(todayDetailWeatherIconName)")
            completion(todayDetailWeather ?? model)
        }
    }
}

//MARK: - 뷰모델 함수

extension HomeViewModel {
    func getTodayRecommendItems(model: [TodayDetailWeatherModel]) -> [String] {
        var weatherItemArr: Set<String> = [] //중복 없애려고 set으로
        for i in 0..<model.count {
            switch model[i] {
            case _ where Int(model[i].tmp) ?? 0 < 5:
                weatherItemArr.insert(" 🧣 🧤")
            case _ where Int(model[i].pop) ?? 0 >= 30 :
                weatherItemArr.insert(" 🌂")
            case _ where model[i].pty != "0":
                weatherItemArr.insert(" 🌂")
            case _ where model[i].sky == "1":
                weatherItemArr.insert(" 🧢 👒")
                weatherItemArr.insert(" 🧴")
            default:
                continue
            }
            
            //MARK: - Todo 겨울에 아이템 추가
            
//            if model[i].tmp < "5º" {
//                weatherItemArr.insert(" 🧣 🧤")
//            }
        }
        
        return Array(weatherItemArr)
    }
    
    func getRainyMent(model: [TodayDetailWeatherModel]) {
        let sortedWeatherPop = model.sorted { Int($0.pop) ?? 0 < Int($1.pop) ?? 0 }
        
        if sortedWeatherPop.filter({ $0.pty == "4" }).count != 0 {
            todayRainyWeatherMent = "소나기가 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else if sortedWeatherPop.filter({ $0.pop != "0" }).count != 0 {
            todayRainyWeatherMent = "오늘 비 올 확률은 최고 \((sortedWeatherPop.last?.pop ?? "0") + "%")입니다 🌧️"
        } else if sortedWeatherPop.filter({ $0.pty == "2" || $0.pty == "2" }).count != 0 {
            todayRainyWeatherMent = "하얀 눈이 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else {
            todayRainyWeatherMent = model.filter { Int($0.tmp) ?? 0 < 5 }.count != 0
            ? "날씨가 추우니 따뜻하게 입어주세요 🧣"
            : ""
        }
    }
    
    func todayWeatherMent(model: WeatherModel) -> String {
        if model.pty == "0" {
            switch model.sky {
            case "1":
                self.todayWeatherLabel = "맑음"
                self.todayWeatherIconName = "sun.max"
                return WeatherMent.sunArr.randomElement()!
            case "3":
                self.todayWeatherLabel = "구름 많음"
                self.todayWeatherIconName = "cloud"
                return WeatherMent.cloudArr.randomElement()!
            case "4":
                self.todayWeatherLabel = "흐림"
                self.todayWeatherIconName = "cloud.sun"
                return WeatherMent.cloudSunArr.randomElement()!
            default:
                return "서버 오류입니다. 앱에서 자세한 날씨를 확인해주세요"
            }
        } else {
            switch model.pty {
            case "1":
                self.todayWeatherLabel = "비"
                self.todayWeatherIconName = "cloud.rain"
                return WeatherMent.rainArr.randomElement()!
            case "2":
                self.todayWeatherLabel = "비/눈"
                self.todayWeatherIconName = "cloud.sleet"
                return WeatherMent.rainSnowArr.randomElement()!
            case "3":
                self.todayWeatherLabel = "눈"
                self.todayWeatherIconName = "cloud.snow"
                return WeatherMent.snowArr.randomElement()!
            case "4":
                self.todayWeatherLabel = "소나기"
                self.todayWeatherIconName = "cloud.sun.rain"
                return WeatherMent.showerArr.randomElement()!
            default:
                return "서버 오류입니다. 앱에서 자세한 날씨를 확인해주세요"
            }
        }
    }
    
    func todayDetailWeatherIcon(model: [TodayDetailWeatherModel]) {
        for i in 0..<WeatherModelCount.todayOneHourWeatherCount.rawValue {
            if model[i].pty == "0" {
                switch model[i].sky {
                case "1":
                    todayDetailWeatherIconName.append("sun.max")
                case "3":
                    todayDetailWeatherIconName.append("cloud")
                case "4":
                    todayDetailWeatherIconName.append("cloud.sun")
                default:
                    todayDetailWeatherIconName.append("sun.max.trianglebadge.exclamationmark")
                }
            } else {
                switch model[i].pty {
                case "1":
                    todayDetailWeatherIconName.append("cloud.rain")
                case "2":
                    todayDetailWeatherIconName.append("cloud.sleet")
                case "3":
                    todayDetailWeatherIconName.append("cloud.snow")
                case "4":
                    todayDetailWeatherIconName.append("cloud.sun.rain")
                default:
                    todayDetailWeatherIconName.append("sun.max.trianglebadge.exclamationmark")
                }
            }
        }
    }
    
    //날씨에 따라 BackgoundImage 바꾸기
    func getHomeViewBackgroundImage(model: WeatherModel) {
        if model.fcstTime > "0600" && model.fcstTime < "2000" {
            if model.pty == "0" {
                switch model.sky {
                case "1":
                    todayBackgroundImage = BackGroundImage.sunny.randomElement() ?? ""
                case "3":
                    todayBackgroundImage = BackGroundImage.cloudy.randomElement() ?? ""
                case "4":
                    todayBackgroundImage = BackGroundImage.cloudy.randomElement() ?? ""
                default:
                    break
                }
            } else {
                switch model.pty {
                case "1", "2", "4":
                    todayBackgroundImage = BackGroundImage.rainy.randomElement() ?? ""
                case "3":
                    todayBackgroundImage = BackGroundImage.snowing.randomElement() ?? ""
                default:
                    break
                }
            }
        } else {
            if model.pty == "0" {
                switch model.sky {
                case "1":
                    todayBackgroundImage = BackGroundImage.sunnyNight.randomElement() ?? ""
                case "3":
                    todayBackgroundImage = BackGroundImage.cloudyNight.randomElement() ?? ""
                case "4":
                    todayBackgroundImage = BackGroundImage.cloudyNight.randomElement() ?? ""
                default:
                    break
                }
            } else {
                switch model.pty {
                case "1", "2", "4":
                    todayBackgroundImage = BackGroundImage.rainyNight.randomElement() ?? ""
                case "3":
                    todayBackgroundImage = BackGroundImage.snowingNight.randomElement() ?? ""
                default:
                    break
                }
            }
        }

    }
    
}
