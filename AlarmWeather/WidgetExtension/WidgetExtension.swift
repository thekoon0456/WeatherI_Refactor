//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/04.
//

import Combine
import CoreLocation
import SwiftUI
import WidgetKit

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
                                    todayWeather: items,
                                    todayWeatherLabel: todayWeatherLabel,
                                    todayWeatherIconName: todayWeatherIconName,
                                    todayTemp: temp,
                                    todayPop: pop)
            let nextRefresh = Calendar.current.date(byAdding: .hour,
                                                    value: 2,
                                                    to: currentDate)!
            let timeline = Timeline(entries: [entry],
                                    policy: .after(nextRefresh))
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

//MARK: - TimelineEntry
/*
 TimelineEntry는 date 라는 필수 프로퍼티를 가지는 프로토콜.
 이 date는 위젯을 업데이트하는 시간.
 위젯을 업데이트하는데 기준이 되는 시간과, 위젯에 표시할 컨텐츠를 설정합니다.
 */

struct WeatherEntry: TimelineEntry {
    let date: Date //시간
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? "위치 인식 실패" //위치
    var todayWeather: [Item]? //기상청 서버에서 가져온 [Item]
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
}


//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry
    var imageURLString = UserDefaults.shared.string(forKey: "imageURLString")
    
    var body: some View {
        ZStack {
            //TODO: - 배경이미지 설정 (현재 로컬 URL 못 받아오는 중)
            if let imageURLString = imageURLString,
               let imageUrl = URL(string: imageURLString) {
                // Image 뷰를 사용하여 로컬 이미지 표시
                Image(uiImage: loadImage(from: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Text("이미지를 찾을 수 없습니다.")
            }
            
            HStack {
                VStack {
                    Image(systemName: entry.todayWeatherIconName ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text(entry.administrativeArea)
                        Text(entry.todayWeatherLabel ?? "날씨 로딩 실패")
                        Text("온도: " + (entry.todayTemp ?? "날씨 로딩 실패") + "º")
                        if entry.todayPop != "0" {
                            Text("강수 확률: " + (entry.todayPop ?? "날씨 로딩 실패") + "%")
                        }
                    }
                    .font(.system(.footnote))
                }
                .padding(7)

                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}

//MARK: - 위젯

struct WidgetExtension: Widget {
    let kind: String = "com.thekoon.NotiWeather.WidgetExtension" //위젯 고유 키
    let provider = Provider()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: provider) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("날씨의 i") //위젯 추가시 디스플레이에 표시되는 앱 이름
        .description("현재 위치의 오늘의 날씨를 확인하세요") //앱 설명
        .supportedFamilies(supportedFamilies) //위젯 사이즈
    }
}


//MARK: - 잠금화면 위젯 설정

extension WidgetExtension {
    private var supportedFamilies:[WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) { //잠금화면 위젯은 iOS16부터
            // iOS 16, 높은 버전 이용자
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular]
        } else {
            // iOS 16, 낮은 버전 이용자
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
}


//MARK: - Image 관련 extension

extension View {
    // 로컬 이미지 파일을 로드하는 함수
    func loadImage(from url: URL) -> UIImage {
        //TODO: - 이미지 URL 인식 불가.
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                print("DEBUG: UIImage 변환 성공")
                return resizeImage(image: image, targetSize: CGSize(width: 500, height: 500))
            }
        } catch {
            print("이미지 로드 중 오류 발생: \(error.localizedDescription)")
        }
        let randomInt = (1...5).randomElement()!
        let originalImage = UIImage(named: "sunnyNight" + "\(randomInt)")
        return resizeImage(image: originalImage!, targetSize: CGSize(width: 500, height: 500))
    }
    
    //파일 사이즈 변경 함수
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // 이미지 크기 비율에 따라 새로운 크기 계산
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // 그래픽 컨텍스트를 만들어 이미지 크기를 조정
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }
}

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        WidgetExtensionEntryView(entry: WeatherEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
