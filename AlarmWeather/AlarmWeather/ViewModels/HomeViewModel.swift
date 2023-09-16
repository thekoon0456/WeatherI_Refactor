//
//  HomeViewModel.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/11.
//

import CoreLocation
import UIKit

import Then

//화면에 보여질 데이터
final class HomeViewModel {
    
    //MARK: - Properties
    
    let weatherService = WeatherService()
    let weeklyWeatherService = WeeklyWeatherService()
    let weeklyWeatherTempService = WeeklyWeatherTempService()
    
    var todayWeather: WeatherModel? //홈에서 사용하는 오늘 날씨 데이터
    var todayWeatherMainMent = "" //홈 메인 멘트
    var todayWeatherIconName = "sun.max.trianglebadge.exclamationmark" //홈 메인 아이콘, 오류시 느낌표
    var todayWeatherLabel = "" //홈 메인 아이콘 아래 날씨
    var todayRainyWeatherMent = ""
    var todayBackgroundImage = BackGroundImage.rainyNight[3] //배경화면 사진
    
    var todayDetailWeather: [TodayDetailWeatherModel]? //컬렉션뷰에서 사용하는 데이터
    var todayOneHourWeather: [TodayDetailWeatherModel]? //24시간 1시간 간격 날씨 함수
    var todayDetailWeatherIconName: [String] = [] //todayDetailIcon
    
    var weeklyWeather: [WeeklyWeatherModel]?
    var weeklyWeatherTemp: [WeeklyWeatherTempModel]?
    var weeklyWeatherIconName: [String] = []
    
    //TODO: -오늘날씨 초단기 실황으로 변경
    
    //서비스의 fetchNow -> 뷰모델 데이터로 변환
    func loadTodayWeather(completion: @escaping (WeatherModel) -> Void) {
        weatherService.fetchTodayWeather { [weak self] model in
            guard let self = self else { return }
            todayWeather = model
            todayWeatherMainMent = self.todayWeatherMent(model: model)
            getHomeViewBackgroundImage(model: model)
            print("DEBUG: TodayBGImage: \(todayBackgroundImage)")
            print("DEBUG: TodayWeatherModel: \(String(describing: todayWeather))")
            completion(self.todayWeather ?? model)
        }
    }
    
    func loadTodayDetailWeather(completion: @escaping ([TodayDetailWeatherModel]) -> Void) {
        weatherService.fetchTodayDetailWeather { [weak self] model in
            guard let self = self else { return }
            todayDetailWeather = model.0
            todayOneHourWeather = model.1 //1시간 간격 추가
            getRainyMent(model: model.1) //1시간 간격으로 오늘 전체 강수량 멘트
            todayDetailWeatherIcon(model: model.0)
            
//            print("DEBUG: detailWeatherIconArr: \(todayDetailWeatherIconName)")
            completion(todayDetailWeather ?? model.0)
        }
    }
    
    func loadWeeklyWeather(completion: @escaping ([WeeklyWeatherModel]) -> Void) {
        weeklyWeatherService.fetchWeeklyWeather { [weak self] model in
            guard let self = self else { return }
            weeklyWeather = model
            print("DEBUG: weeklyWeather: \(String(describing: weeklyWeather))")
            weeklyWeatherIconName(model: model)
            print("DEBUG: weeklyWeatherIconArr: \(self.weeklyWeatherIconName)")
            completion(weeklyWeather ?? model)
        }
    }
    
    func loadWeeklyWeatherTemp(completion: @escaping ([WeeklyWeatherTempModel]) -> Void) {
        weeklyWeatherTempService.fetchWeeklyWeatherTemp { [weak self] model in
            guard let self = self else { return }
            weeklyWeatherTemp = model
            print("DEBUG: weeklyWeatherTemp: \(String(describing: weeklyWeatherTemp))")
            completion(weeklyWeatherTemp ?? model)
        }
    }
}

//MARK: - 뷰모델 함수

extension HomeViewModel {
    func todayWeatherMent(model: WeatherModel) -> String {
        if model.pty == "0" {
            switch model.sky {
            case "1":
                todayWeatherLabel = "맑음"
                todayWeatherIconName = "sun.max"
                return WeatherMent.sunArr.randomElement()!
            case "3":
                todayWeatherLabel = "구름 많음"
                todayWeatherIconName = "cloud"
                return WeatherMent.cloudArr.randomElement()!
            case "4":
                todayWeatherLabel = "흐림"
                todayWeatherIconName = "cloud.sun"
                return WeatherMent.cloudSunArr.randomElement()!
            default:
                return "서버 오류입니다. 아래로 당겨 새로고침 해주세요"
            }
        } else {
            switch model.pty {
            case "1":
                todayWeatherLabel = "비"
                todayWeatherIconName = "cloud.rain"
                return WeatherMent.rainArr.randomElement()!
            case "2":
                todayWeatherLabel = "비/눈"
                todayWeatherIconName = "cloud.sleet"
                return WeatherMent.rainSnowArr.randomElement()!
            case "3":
                todayWeatherLabel = "눈"
                todayWeatherIconName = "cloud.snow"
                return WeatherMent.snowArr.randomElement()!
            case "4":
                todayWeatherLabel = "소나기"
                todayWeatherIconName = "cloud.sun.rain"
                return WeatherMent.showerArr.randomElement()!
            default:
                return "서버 오류입니다. 아래로 당겨 새로고침 해주세요"
            }
        }
    }
    
    func getRainyMent(model: [TodayDetailWeatherModel]) {
        let sortedWeatherPop = model.sorted { Int($0.pop) ?? 0 < Int($1.pop) ?? 0 }

        if sortedWeatherPop.filter({ $0.pty == "4" }).count != 0 {
            todayRainyWeatherMent = "소나기가 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else if sortedWeatherPop.filter({ $0.pop != "0" }).count != 0 {
            if sortedWeatherPop[0].pop == sortedWeatherPop[sortedWeatherPop.count - 1].pop {
                todayRainyWeatherMent = "오늘 비 올 확률은 \(sortedWeatherPop[0].pop + "%") 입니다 🌧️"
            } else {
                todayRainyWeatherMent = "오늘 비 올 확률은 \(sortedWeatherPop[0].pop + "%") ~ \(sortedWeatherPop[sortedWeatherPop.count - 1].pop + "%") 입니다 🌧️"
            }
        } else if sortedWeatherPop.filter({ $0.pty == "2" || $0.pty == "2" }).count != 0 {
            todayRainyWeatherMent = "하얀 눈이 올 수 있으니 우산 챙기시는걸 추천드려요 ☂️"
        } else {
            todayRainyWeatherMent = ""
        }
    }
    
    //MARK: - cell 숫자 모델과 맞추기
    func todayDetailWeatherIcon(model: [TodayDetailWeatherModel]) {
        for i in 0..<WeatherModelCount.todayDetailWeatherCount.rawValue {
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
    
    func weeklyWeatherIconName(model: [WeeklyWeatherModel]) {
        for i in 0..<7 {
            switch model[i].wf {
            case "맑음":
                weeklyWeatherIconName.append("sun.max")
            case "구름많음":
                weeklyWeatherIconName.append("cloud")
            case "구름많고 비", "구름많고 소나기":
                weeklyWeatherIconName.append("cloud.rain")
            case "구름많고 눈", "흐리고 눈":
                weeklyWeatherIconName.append("cloud.snow")
            case "구름많고 비/눈", "흐리고 비/눈":
                weeklyWeatherIconName.append("cloud.sleet")
            case "흐림":
                weeklyWeatherIconName.append("cloud.sun")
            case "흐리고 비", "흐리고 소나기":
                weeklyWeatherIconName.append("cloud.sun.rain")
            default:
                self.weeklyWeatherIconName.append("sun.max.trianglebadge.exclamationmark")
                print("DEBUG: weeklyWeatherIcon 오류")
            }
        }
    }
    
    //날씨에 따라 BackgoundImage 바꾸기
    //TODO: -다양한 사진 넣어 랜덤으로 나오도록 추가 완료. 코드 정리하기
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
