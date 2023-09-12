//
//  WidgetProvider.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/12.
//

import Combine
import SwiftUI
import WidgetKit

final class Provider: TimelineProvider {
    private var weatherNetwork = WeatherNetwork()
    private var todayWeatherLabel: String?
    private var todayWeatherIconName: String?
    private var temp: String?
    private var pop: String?
    private var cancellables = Set<AnyCancellable>()
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date()) //현재 시간
    }
    
    // 이 함수는 위젯의 초기 스냅샷을 제공합니다.
    // 스냅샷은 위젯이 업데이트되기 전에 보여지는 초기 데이터
    // 주로 고정된 데이터를 표시하거나, 이전 업데이트에서 캐싱된 데이터를 빠르게 표시하는 데 사용됩니다.
    // 위젯 갤러리에서 위젯을 고를 때 보이는 샘플 데이터를 보여줄때 해당 메소드 호출
    // API를 통해서 데이터를 fetch하여 보여줄때 딜레이가 있는 경우 여기서 샘플 데이터를 하드코딩해서 보여주는 작업도 가능
    // context.isPreview가 true인 경우 위젯 갤러리에 위젯이 표출되는 상태
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        getData { [weak self] items in
            guard let self else { return }
            todayWeatherState(model: items)
            getTempAndPop(model: items)
            let entry = WeatherEntry(date: Date(),
                                     imageURL: UserDefaults.shared.string(forKey: "imageURLString"),
                                     todayWeather: items,
                                     todayWeatherLabel: todayWeatherLabel,
                                     todayWeatherIconName: todayWeatherIconName,
                                     todayTemp: temp,
                                     todayPop: pop)
            completion(entry)
        }
    }
    
    //WidgetKit은 Provider에게 TimeLine을 요청
    // 이 함수는 위젯의 타임라인을 정의하고 업데이트 주기를 관리합니다.
    // 위젯의 데이터를 업데이트하고 새로운 엔트리를 생성하는 데 사용됩니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getData { [weak self] items in
            guard let self else { return }
            todayWeatherState(model: items)
            getTempAndPop(model: items)
            let currentDate = Date()
            let entry = WeatherEntry(date: currentDate,
                                     imageURL: UserDefaults.shared.string(forKey: "imageURLString"),
                                     todayWeather: items,
                                     todayWeatherLabel: todayWeatherLabel,
                                     todayWeatherIconName: todayWeatherIconName,
                                     todayTemp: temp,
                                     todayPop: pop)
            // 업데이트 주기 설정
            let updateFrequency = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(updateFrequency))

            completion(timeline)
        }
    }
}


//MARK: - 데이터 관련 함수

extension Provider {
    private func getData(completion: @escaping ([Item]?) -> Void) {
        weatherNetwork
            .fetchWeatherData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("DEBUG: sink 성공")
                    break
                case .failure(let error):
                    print("DEBUG: \(error)")
                }
            }, receiveValue: { model in
                let items = model.response.body.items.item
                print("DEBUG item: \(items)")
                completion(items)
            })
            .store(in: &cancellables)
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
