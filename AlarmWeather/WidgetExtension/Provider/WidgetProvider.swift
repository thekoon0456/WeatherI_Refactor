//
//  WidgetProvider.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/12.
//

import Combine
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
    let data: WidgetData
}

struct WidgetData: Equatable {
    var todayBackgroundImage: String?
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea")
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todaySky: String?
    var todayPty: String?
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
    var fcstTime: String?
    var updateTime: Date?
}

//MARK: - TimelineProvider
/*
 위젯의 업데이트할 시기를 WidgetKit에 알려줌.
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공
 */

final class Provider: TimelineProvider {
    private var weatherNetwork = WeatherNetwork()
    private var cancellables: Set<AnyCancellable> = []
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(date: Date(), data: WidgetData()) //현재 시간
    }
    
    // 위젯 미리보기 스냅샷
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        getData()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("DEBUG: sink 성공")
                case .failure(let error):
                    print("DEBUG: \(error)")
                }
            }, receiveValue: { [weak self] widgetData in
                guard let self else { return }
                var widgetData = widgetData
                widgetData.todayWeatherLabel = todayWeatherState(model: widgetData).weatherState
                widgetData.todayWeatherIconName = todayWeatherState(model: widgetData).iconName
                widgetData.todayTemp = getTempAndPop(model: widgetData).temp
                widgetData.todayPop = getTempAndPop(model: widgetData).pop
                widgetData.todayBackgroundImage = getHomeViewBackgroundImage(model: widgetData)
                
                let completeData = widgetData
                let entry = WeatherEntry(date: Date(),
                                         data: completeData)
                completion(entry)
            })
            .store(in: &cancellables)
    }
    
    //WidgetKit은 Provider에게 TimeLine을 요청
    // 이 함수는 위젯의 타임라인을 정의하고 업데이트 주기를 관리합니다.
    // 위젯의 데이터를 업데이트하고 새로운 엔트리를 생성하는 데 사용됩니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        getData()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("DEBUG: sink 성공")
                case .failure(let error):
                    print("DEBUG: \(error)")
                }
            }, receiveValue: { [weak self] widgetData in
                guard let self else { return }
                var widgetData = widgetData
                widgetData.todayWeatherLabel = todayWeatherState(model: widgetData).weatherState
                widgetData.todayWeatherIconName = todayWeatherState(model: widgetData).iconName
                widgetData.todayTemp = getTempAndPop(model: widgetData).temp
                widgetData.todayPop = getTempAndPop(model: widgetData).pop
                widgetData.todayBackgroundImage = getHomeViewBackgroundImage(model: widgetData)
                
                var completeData = widgetData
                var entries: [WeatherEntry] = []
                let hourOffsets = [2, 4, 6, 8]
                let currentDate = Date()
                
                for hourOffset in hourOffsets {
                    // 엔트리 생성
                    let entryDate = Calendar.current.date(byAdding: .hour,
                                                          value: hourOffset,
                                                          to: currentDate) ?? Date()
                    completeData.updateTime = entryDate
                    let entry = WeatherEntry(date: entryDate,
                                             data: completeData)
                    entries.append(entry)
                }
                
                dump("DEBUG: entries: \(entries)")
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

//MARK: - 데이터 관련 함수

extension Provider {
    private func getData() -> AnyPublisher<WidgetData, Error> {
        return weatherNetwork
            .fetchWeatherData()
            .map { model in
                return model.response.body.items.item
            }
            .map { data in
//                print(data)
                let todaySky = data.filter({ $0.category == "SKY" }).first?.fcstValue
                let todayPty = data.filter({ $0.category == "PTY" }).first?.fcstValue
                let todayTemp = data.filter { $0.category == "TMP" }.first?.fcstValue
                let todayPop = data.filter { $0.category == "POP" }.first?.fcstValue
                let fcstTime = data.first?.fcstTime
                
                return WidgetData(todaySky: todaySky,
                                  todayPty: todayPty,
                                  todayTemp: todayTemp,
                                  todayPop: todayPop,
                                  fcstTime: fcstTime)
            }
//            .print()
            .receive(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    private func todayWeatherState(model: WidgetData) -> (weatherState: String, iconName: String) {
        if model.todayPty == "0" {
            switch model.todaySky {
            case "1":
                return ("맑음", "sun.max")
            case "3":
                return ("구름 많음", "cloud")
            case "4":
                return ("흐림", "cloud.sun")
            default:
                return ("", "")
            }
        } else {
            switch model.todayPty {
            case "1":
                return ("비", "cloud.rain")
            case "2":
                return ("비/눈", "cloud.sleet")
            case "3":
                return ("눈", "cloud.snow")
            case "4":
                return ("소나기", "cloud.sun.rain")
            default:
                return ("", "")
            }
        }
    }
    
    private func getTempAndPop(model: WidgetData) -> (temp: String?, pop: String?) {
        return (model.todayTemp, model.todayPop)
    }
}

//MARK: - 위젯 백그라운드 설정

extension Provider {
    func getHomeViewBackgroundImage(model: WidgetData) -> String {
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
                    return ""
                }
            } else {
                switch model.todayPty {
                case "1", "2", "4":
                    return BackGroundImage.rainy.randomElement() ?? ""
                case "3":
                    return BackGroundImage.snowing.randomElement() ?? ""
                default:
                    return ""
                }
            }
        } else {
            if model.todayPty == "0" {
                switch model.todaySky {
                case "1":
                    return BackGroundImage.sunnyNight.randomElement() ?? ""
                case "3":
                    return BackGroundImage.cloudyNight.randomElement() ?? ""
                case "4":
                    return BackGroundImage.cloudyNight.randomElement() ?? ""
                default:
                    return ""
                }
            } else {
                switch model.todayPty {
                case "1", "2", "4":
                    return BackGroundImage.rainyNight.randomElement() ?? ""
                case "3":
                    return BackGroundImage.snowingNight.randomElement() ?? ""
                default:
                    return ""
                }
            }
        }
    }
}
