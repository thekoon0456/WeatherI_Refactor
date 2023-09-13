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
    let view: WidgetExtensionEntryView
}

struct WidgetData: Equatable {
    var imageURL: String?
    var todayBackgroundImage: String?
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? "위치 인식 실패" //위치
    var todayWeather: [Item]? //기상청 서버에서 가져온 [Item]
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
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
    private var widgetData = WidgetData()
//    private lazy var widgetView = WidgetExtensionEntryView(data: widgetData)
    private var cancellables: [AnyCancellable] = []

    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> WeatherEntry {
        let widgetView = WidgetExtensionEntryView(data: widgetData)
        return WeatherEntry(date: Date(), view: widgetView) //현재 시간
    }
    
    // 이 함수는 위젯의 초기 스냅샷을 제공합니다.
    // 초기 로딩에서 한번 호출됨
    // API를 통해서 데이터를 fetch하여 보여줄때 딜레이가 있는 경우 여기서 샘플 데이터를 하드코딩해서 보여주는 작업도 가능
    // context.isPreview가 true인 경우 위젯 갤러리에 위젯이 표출되는 상태
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        getData()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("DEBUG: sink 성공")
                case .failure(let error):
                    print("DEBUG: \(error)")
                }
            }, receiveValue: { [weak self] items in
                guard let self else { return }
                todayWeatherState(model: items)
                getTempAndPop(model: items)
                getHomeViewBackgroundImage(model: items)
                widgetData.updateTime = Date()
                let widgetView = WidgetExtensionEntryView(data: widgetData)
                
                print("스냅샷 함수 실행데이터: \(widgetData)")
//                print(widgetData.todayWeatherLabel)
//                print(widgetData.todayTemp)
//                print(widgetData.todayPop)
                let entry = WeatherEntry(date: Date(),
                                         view: widgetView)
                
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
            }, receiveValue: { [weak self] items in
                guard let self else { return }
                todayWeatherState(model: items)
                getTempAndPop(model: items)
                getHomeViewBackgroundImage(model: items)

                var entries: [WeatherEntry] = []
                let currentDate = Date()
                
                for hourOffset in 0 ..< 2 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                    
//                    print(items?.filter { $0.category == "TMP" }.first )
//                    print(items?.filter { $0.category == "SKY" }.first )
//                    print(items?.filter { $0.category == "POP" }.first )
                    widgetData.updateTime = entryDate
                    
                    let widgetView = WidgetExtensionEntryView(data: widgetData)
                    
                    print(widgetData.todayWeatherIconName)
                    print(widgetData.todayWeatherLabel)
                    print(widgetData.todayTemp)
                    print(widgetData.todayPop)
                    print(entryDate)
                    
                    let entry = WeatherEntry(date: entryDate,
                                             view: widgetView)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

//MARK: - 데이터 관련 함수

extension Provider {
    private func getData() -> AnyPublisher<[Item]?, Error> {
        return weatherNetwork
            .fetchWeatherData()
            .map { model in
                return model.response.body.items.item
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func todayWeatherState(model: [Item]?) {
        if model?.filter({ $0.category == "PTY" }).first?.fcstValue == "0" {
            switch model?.filter({ $0.category == "SKY" }).first?.fcstValue {
            case "1":
                widgetData.todayWeatherLabel = "맑음"
                widgetData.todayWeatherIconName = "sun.max"
            case "3":
                widgetData.todayWeatherLabel = "구름 많음"
                widgetData.todayWeatherIconName = "cloud"
            case "4":
                widgetData.todayWeatherLabel = "흐림"
                widgetData.todayWeatherIconName = "cloud.sun"
            default:
                break
            }
        } else {
            switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
            case "1":
                widgetData.todayWeatherLabel = "비"
                widgetData.todayWeatherIconName = "cloud.rain"
            case "2":
                widgetData.todayWeatherLabel = "비/눈"
                widgetData.todayWeatherIconName = "cloud.sleet"
            case "3":
                widgetData.todayWeatherLabel = "눈"
                widgetData.todayWeatherIconName = "cloud.snow"
            case "4":
                widgetData.todayWeatherLabel = "소나기"
                widgetData.todayWeatherIconName = "cloud.sun.rain"
            default:
                break
            }
        }
    }
    
    private func getTempAndPop(model: [Item]?) {
        widgetData.todayTemp = model?.filter { $0.category == "TMP" }.first?.fcstValue
        widgetData.todayPop = model?.filter { $0.category == "POP" }.first?.fcstValue
    }
}

//MARK: - 위젯 백그라운드 설정

extension Provider {
    func getHomeViewBackgroundImage(model: [Item]?) {
        if model?.first?.fcstTime ?? "" < "0600"  && model?.first?.fcstTime ?? "" > "2000" {
            if model?.filter({ $0.category == "PTY" }).first?.fcstValue == "0" {
                switch model?.filter({ $0.category == "SKY" }).first?.fcstValue {
                case "1":
                    widgetData.todayBackgroundImage = BackGroundImage.sunny.randomElement() ?? ""
                case "3":
                    widgetData.todayBackgroundImage = BackGroundImage.cloudy.randomElement() ?? ""
                case "4":
                    widgetData.todayBackgroundImage = BackGroundImage.cloudy.randomElement() ?? ""
                default:
                    break
                }
            } else {
                switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
                case "1", "2", "4":
                    widgetData.todayBackgroundImage = BackGroundImage.rainy.randomElement() ?? ""
                case "3":
                    widgetData.todayBackgroundImage = BackGroundImage.snowing.randomElement() ?? ""
                default:
                    break
                }
            }
        } else {
            if model?.filter({ $0.category == "PTY" }).first?.fcstValue == "0" {
                switch model?.filter({ $0.category == "SKY" }).first?.fcstValue {
                case "1":
                    widgetData.todayBackgroundImage = BackGroundImage.sunnyNight.randomElement() ?? ""
                case "3":
                    widgetData.todayBackgroundImage = BackGroundImage.cloudyNight.randomElement() ?? ""
                case "4":
                    widgetData.todayBackgroundImage = BackGroundImage.cloudyNight.randomElement() ?? ""
                default:
                    break
                }
            } else {
                switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
                case "1", "2", "4":
                    widgetData.todayBackgroundImage = BackGroundImage.rainyNight.randomElement() ?? ""
                case "3":
                    widgetData.todayBackgroundImage = BackGroundImage.snowingNight.randomElement() ?? ""
                default:
                    break
                }
            }
        }
    }
}
