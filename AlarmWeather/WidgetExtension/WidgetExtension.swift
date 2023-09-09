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
 공식문서에서 TimelineProvider 정의를 "위젯의 업데이트할 시기를 WidgetKit에 알려준다."
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청합니다.
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공하는 것이죠.
 TimelineEntry과 마찬가지로 TimelineProvider 도 프로토콜입니다.
 */

class Provider: TimelineProvider {
//    var viewModel: HomeViewModel = HomeViewModel()
//    var dustViewModel: DustViewModel = DustViewModel()
    
    var weatherNetwork = WeatherNetwork()
    
    private var cancellables = Set<AnyCancellable>()
    
    func getData(completion: @escaping ([Item]?) -> Void) {
        weatherNetwork
            .fetchWeatherData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("DEBUG: sink 성공")
                    break // 성공적으로 완료된 경우 아무 작업도 필요 없음
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
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date()) //현재 시간
    }
    
    // 위젯 갤러리에서 위젯을 고를 때 보이는 샘플 데이터를 보여줄때 해당 메소드 호출
    // API를 통해서 데이터를 fetch하여 보여줄때 딜레이가 있는 경우 여기서 샘플 데이터를 하드코딩해서 보여주는 작업도 가능
    // context.isPreview가 true인 경우 위젯 갤러리에 위젯이 표출되는 상태
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        getData { items in
            let entry = SimpleEntry(date: Date(), todayWeather: items)
            completion(entry)
        }
    }
    
    //WidgetKit은 Provider에게 TimeLine을 요청
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        getData { WeatherModel in
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate)
            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
        
        //context: TimelineProviderContext
        //TimelineProviderContext는 Widget이 렌더링되는 방법에 대한 세부 정보가 포함된 객체에요.
        /*
         isPreview: 프리뷰 상황에서 그려줌
         family: WidgetFamily. switch로 분기처리해서 사용
         displaySize: Widget의 point size
         environmentVariantes: Widget이 표시될 때 설정될 수 있는 모든 environment values. ex) .colorScheme
         */
        /* ex)
         if context.isPreview {
             entry = SimpleEntry(date: Date(), title: "Preview")
         } else {
             entry = SimpleEntry(date: Date())
         }
         */

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        var entries: [SimpleEntry] = []
//        let currentDate = Date()
//
//        for hourOffset in 0 ..< 5 { //1시간씩
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, )
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd) //policy: TimelineReloadPolicy, .atEnd 위젯 끝나면 다시 타임라인 요청
//        completion(timeline)
    }
}

//MARK: - TimelineEntry
/*
 TimelineEntry는 date 라는 필수 프로퍼티를 가지는 프로토콜이고 이 date는 위젯을 업데이트하는 시간을 담고 있다.
 공식문서 의 TimelineEntry 정의를 간단히 해석하면 위젯을 표시할 날짜를 지정,
 위젯 콘텐츠의 현재 관련성 이라고 해석됩니다.
 기본적으로 TimelineEntry 는 기본적으로 프로토콜이고 date 프로퍼티를 필수로 요구합니다.
 */

struct SimpleEntry: TimelineEntry {
    let date: Date
    var todayWeather: [Item]?
    var x = UserDefaults.shared.integer(forKey: "convertedX")
    var y = UserDefaults.shared.integer(forKey: "convertedY")
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? ""
    
//    var todayDust: DustModel?
}


//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry
    
    var imageURLString = UserDefaults.shared.string(forKey: "imageURLString")
    
    var body: some View {
        //        switch widgetFamily {
        //        case .systemSmall:
        //            Text("systemSmall")
        //        case .systemMedium:
        //            Text("systemMedium")
        //        case .systemLarge:
        //            Text("systemLarge")
        //        @unknown default:
        //            Text("unknown")
        //        }
        VStack {
            // 로컬 이미지 파일의 경로를 지정
            if let imageURLString = imageURLString,
               let imageUrl = URL(string: imageURLString) {
                // Image 뷰를 사용하여 로컬 이미지 표시
                Image(uiImage: loadImage(from: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200) // 이미지 크기 조절
            } else {
                Text("이미지를 찾을 수 없습니다.")
            }
            
            Text(String(entry.x))
            Text(String(entry.y))
            Text(entry.administrativeArea)
            Text(entry.todayWeather?.first?.fcstTime ?? "데이터 로딩 실패")
            Text(entry.todayWeather?.first?.fcstValue ?? "데이터 로딩 실패")
            
            //            //위젯 업데이트
            //            Button {
//                WidgetCenter.shared.reloadAllTimelines()
//            } label: {
//                Text("새로고침")
//            }
        }

    }
    
//DEBUG: imageURLs: [file:///var/mobile/Containers/Data/Application/A1E90269-774E-4B69-8EE8-84E2A63921CE/Documents/images/ED34969C-5A36-4A9E-91CF-A7A0EF7768C9.png]
    
    // 로컬 이미지 파일을 로드하는 함수
    func loadImage(from url: URL) -> UIImage {
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                print("DEBUG: UIImage 변환 성공")
                return image
            }
        } catch {
            print("로컬 이미지 로드 중 오류 발생: \(error.localizedDescription)")
        }
        
        return UIImage(systemName: "photo") ?? UIImage()
    }
}

//MARK: - 위젯

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"
    let provider = Provider()
    
    private let supportedFamilies:[WidgetFamily] = {
        if #available(iOSApplicationExtension 16.0, *) { //잠금화면 위젯은 iOS16부터
            // iOS 16, 높은 버전 이용자
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular]
        } else {
            // iOS 16, 낮은 버전 이용자
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: provider) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("날씨의 i") //위젯 추가시 디스플레이에 표시되는 앱 이름
        .description("현재 위치의 오늘의 날씨를 확인하세요") //앱 설명
        .supportedFamilies(supportedFamilies)
    }
}

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
