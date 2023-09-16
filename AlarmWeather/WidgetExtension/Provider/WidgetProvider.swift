//
//  WidgetProvider.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/12.
//

import SwiftUI
import WidgetKit

//MARK: - TimelineEntry
/*
 TimelineEntry는 date 라는 필수 프로퍼티를 가지는 프로토콜.
 이 date는 위젯을 업데이트하는 시간.
 위젯을 업데이트하는데 기준이 되는 시간과, 위젯에 표시할 컨텐츠를 설정합니다.
 */

struct WeatherEntry: TimelineEntry {
    let date: Date //시간
    let data: WidgetViewModel
}

struct WidgetData: Equatable {
    var todaySky: String?
    var todayPty: String?
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
    var fcstTime: String?
}

struct WidgetViewModel {
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea")
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
    var todayBackgroundImage: String? //위젯 날씨 배경화면
    var updateTime: Date? //새로고침한 시간
}

//MARK: - TimelineProvider
/*
 위젯의 업데이트할 시기를 WidgetKit에 알려줌.
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공
 */

final class Provider: TimelineProvider {
    private var weatherNetwork = WeatherNetwork()
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 위젯데이터
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(), data: WidgetViewModel(todayWeatherLabel: "맑음",
                                                                todayWeatherIconName: "sun.max",
                                                                todayTemp: "23",
                                                                todayPop: "0",
                                                                todayBackgroundImage: "sunny1"))
    }
    
    // 위젯 미리보기 스냅샷 (데이터 로드한 뒤)
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        getData { [weak self] widgetData in
            guard let self else { return }
            
            let todayWeatherLabel = getTodayState(model: widgetData)
            let todayWeatherIconName = getTodayIconName(model: widgetData)
            let todayTemp = getTemp(model: widgetData)
            let todayPop = getPop(model: widgetData)
            let todayBackgroundImage = getHomeViewBackgroundImage(model: widgetData)
            
            let widgetViewModel = WidgetViewModel(todayWeatherLabel: todayWeatherLabel,
                                                  todayWeatherIconName: todayWeatherIconName,
                                                  todayTemp: todayTemp,
                                                  todayPop: todayPop,
                                                  todayBackgroundImage: todayBackgroundImage)
            
            let entry = WeatherEntry(date: Date(),
                                     data: widgetViewModel)
            
            completion(entry)
        }
    }
    
    //WidgetKit은 Provider에게 TimeLine을 요청
    // 이 함수는 위젯의 타임라인을 정의하고 업데이트 주기를 관리합니다.
    // 위젯의 데이터를 업데이트하고 새로운 엔트리를 생성하는 데 사용됩니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        getData { [weak self] widgetData in
            guard let self else { return }
            
            let todayWeatherLabel = getTodayState(model: widgetData)
            let todayWeatherIconName = getTodayIconName(model: widgetData)
            let todayTemp = getTemp(model: widgetData)
            let todayPop = getPop(model: widgetData)
            let todayBackgroundImage = getHomeViewBackgroundImage(model: widgetData)
            
            var widgetViewModel = WidgetViewModel(todayWeatherLabel: todayWeatherLabel,
                                                  todayWeatherIconName: todayWeatherIconName,
                                                  todayTemp: todayTemp,
                                                  todayPop: todayPop,
                                                  todayBackgroundImage: todayBackgroundImage)
            
            let currentDate = Date()
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
            
            //MARK: - Test(Update 시간 확인)
            widgetViewModel.updateTime = nextRefresh
            
            let entry = WeatherEntry(date: currentDate,
                                     data: widgetViewModel)
            
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            print("DEBUG: timeline: \(timeline)")
            completion(timeline)
        }
    }
}

//MARK: - 데이터 관련 함수

extension Provider {
    private func getData(completion: @escaping (WidgetData) -> Void) {
        let weatherNetwork = WeatherNetwork()
        weatherNetwork.performRequest { (result: Result<[Item], NetworkError>) in
            switch result {
            case .success(let data):
                let todaySky = data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == "SKY" }.first?.fcstValue ?? ""
                let todayPty = data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == "PTY" }.first?.fcstValue ?? ""
                let todayTemp = data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == "TMP" }.first?.fcstValue ?? ""
                let todayPop = data.filter { $0.fcstDate == DateAndTime.todayDate && $0.category == "POP" }.first?.fcstValue ?? ""
                let fcstTime = data.filter { $0.fcstTime == DateAndTime.currentTime }.first?.fcstTime ?? ""
                
                let widgetData =  WidgetData(todaySky: todaySky,
                                             todayPty: todayPty,
                                             todayTemp: todayTemp,
                                             todayPop: todayPop,
                                             fcstTime: fcstTime)
                
                completion(widgetData)
                
            case .failure(let error):
                print("DEBUG: getData Error: \(error.localizedDescription)")
            }
        }
    }
}
    
//MARK: - 뷰모델 함수

extension Provider {
    private func getTodayState(model: WidgetData) -> String {
        if model.todayPty == "0" {
            switch model.todaySky {
            case "1":
                return "맑음"
            case "3":
                return "구름 많음"
            case "4":
                return "흐림"
            default:
                return "맑음"
            }
        } else {
            switch model.todayPty {
            case "1":
                return "비"
            case "2":
                return "비/눈"
            case "3":
                return "눈"
            case "4":
                return "소나기"
            default:
                return "비"
            }
        }
    }
    
    private func getTodayIconName(model: WidgetData) -> String {
        if model.todayPty == "0" {
            switch model.todaySky {
            case "1":
                return "sun.max"
            case "3":
                return "cloud"
            case "4":
                return "cloud.sun"
            default:
                return "sun.max"
            }
        } else {
            switch model.todayPty {
            case "1":
                return "cloud.rain"
            case "2":
                return "cloud.sleet"
            case "3":
                return "cloud.snow"
            case "4":
                return "cloud.sun.rain"
            default:
                return "cloud.rain"
            }
        }
    }
    
    private func getTemp(model: WidgetData) -> String? {
        return model.todayTemp
    }
    
    private func getPop(model: WidgetData) -> String? {
        return model.todayPop
    }
}

//MARK: - 위젯 백그라운드 설정

extension Provider {
    func getHomeViewBackgroundImage(model: WidgetData) -> String {
        //낮시간일때 낮 이미지
        if model.fcstTime ?? "" >= "0600"  && model.fcstTime ?? "" <= "2000" {
            if model.todayPty == "0" {
                switch model.todaySky {
                case "1":
                    return BackGroundImage.sunny.randomElement() ?? ""
                case "3":
                    return BackGroundImage.cloudy.randomElement() ?? ""
                case "4":
                    return BackGroundImage.cloudy.randomElement() ?? ""
                default:
                    return BackGroundImage.sunny.randomElement() ?? ""
                }
            } else {
                switch model.todayPty {
                case "1", "2", "4":
                    return BackGroundImage.rainy.randomElement() ?? ""
                case "3":
                    return BackGroundImage.snowing.randomElement() ?? ""
                default:
                    return BackGroundImage.rainy.randomElement() ?? ""
                }
            }
        } else { //밤 시간부터 밤 이미지
            if model.todayPty == "0" {
                switch model.todaySky {
                case "1":
                    return BackGroundImage.sunnyNight.randomElement() ?? ""
                case "3":
                    return BackGroundImage.cloudyNight.randomElement() ?? ""
                case "4":
                    return BackGroundImage.cloudyNight.randomElement() ?? ""
                default:
                    return BackGroundImage.sunnyNight.randomElement() ?? ""
                }
            } else {
                switch model.todayPty {
                case "1", "2", "4":
                    return BackGroundImage.rainyNight.randomElement() ?? ""
                case "3":
                    return BackGroundImage.snowingNight.randomElement() ?? ""
                default:
                    return BackGroundImage.rainyNight.randomElement() ?? ""
                }
            }
        }
    }
}
