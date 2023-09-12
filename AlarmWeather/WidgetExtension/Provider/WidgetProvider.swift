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
    var imageURL: String?
    var todayBackgroundImage: String?
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? "위치 인식 실패" //위치
    var todayWeather: [Item]? //기상청 서버에서 가져온 [Item]
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
}

//MARK: - TimelineProvider
/*
 위젯의 업데이트할 시기를 WidgetKit에 알려줌.
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공
 */

final class Provider: TimelineProvider {
    private var weatherNetwork = WeatherNetwork()
    private var todayWeatherLabel: String?
    private var todayWeatherIconName: String?
    private var temp: String?
    private var pop: String?
    private var cancellables: [AnyCancellable] = []
    private var todayBackgroundImage: String?
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date()) //현재 시간
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
                
                let entry = WeatherEntry(date: Date(),
                                         imageURL: UserDefaults.shared.string(forKey: "imageURLString"),
                                         todayBackgroundImage: todayBackgroundImage,
                                         todayWeather: items,
                                         todayWeatherLabel: todayWeatherLabel,
                                         todayWeatherIconName: todayWeatherIconName,
                                         todayTemp: temp,
                                         todayPop: pop)
                
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
                
                let currentDate = Date()
                let entryDate = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!
                
                let entry = WeatherEntry(date: currentDate,
                                         imageURL: UserDefaults.shared.string(forKey: "imageURLString"),
                                         todayBackgroundImage: todayBackgroundImage,
                                         todayWeather: items,
                                         todayWeatherLabel: todayWeatherLabel,
                                         todayWeatherIconName: todayWeatherIconName,
                                         todayTemp: temp,
                                         todayPop: pop)
                
                let timeline = Timeline(entries: [entry], policy: .after(entryDate))
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
                todayWeatherLabel = "맑음"
                todayWeatherIconName = "sun.max"
            case "3":
                todayWeatherLabel = "구름 많음"
                todayWeatherIconName = "cloud"
            case "4":
                todayWeatherLabel = "흐림"
                todayWeatherIconName = "cloud.sun"
            default:
                break
            }
        } else {
            switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
            case "1":
                todayWeatherLabel = "비"
                todayWeatherIconName = "cloud.rain"
            case "2":
                todayWeatherLabel = "비/눈"
                todayWeatherIconName = "cloud.sleet"
            case "3":
                todayWeatherLabel = "눈"
                todayWeatherIconName = "cloud.snow"
            case "4":
                todayWeatherLabel = "소나기"
                todayWeatherIconName = "cloud.sun.rain"
            default:
                break
            }
        }
    }
    
    private func getTempAndPop(model: [Item]?) {
        temp = model?.filter { $0.category == "TMP" }.first?.fcstValue
        pop = model?.filter { $0.category == "POP" }.first?.fcstValue
    }
}

//MARK: - 위젯 백그라운드 설정

extension Provider {
    func getHomeViewBackgroundImage(model: [Item]?) {
        if model?.first?.fcstTime ?? "" < "0600"  && model?.first?.fcstTime ?? "" > "2000" {
            if model?.filter({ $0.category == "PTY" }).first?.fcstValue == "0" {
                switch model?.filter({ $0.category == "SKY" }).first?.fcstValue {
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
                switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
                case "1", "2", "4":
                    todayBackgroundImage = BackGroundImage.rainy.randomElement() ?? ""
                case "3":
                    todayBackgroundImage = BackGroundImage.snowing.randomElement() ?? ""
                default:
                    break
                }
            }
        } else {
            if model?.filter({ $0.category == "PTY" }).first?.fcstValue == "0" {
                switch model?.filter({ $0.category == "SKY" }).first?.fcstValue {
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
                switch model?.filter({ $0.category == "PTY" }).first?.fcstValue {
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
