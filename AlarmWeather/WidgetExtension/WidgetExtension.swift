//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/04.
//

import WidgetKit
import SwiftUI

//MARK: - TimelineProvider
/*
 공식문서에서 TimelineProvider 정의를 "위젯의 업데이트할 시기를 WidgetKit에 알려준다."
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청합니다.
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공하는 것이죠.
 TimelineEntry과 마찬가지로 TimelineProvider 도 프로토콜입니다.
 */

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date()) //현재 시간
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    //WidgetKit은 Provider에게 TimeLine을 요청
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 2 { //2시간마다 업데이트
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd) //.atEnd 위젯 끝나면 다시 타임라인 요청
        completion(timeline)
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
}


//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            
            //위젯 업데이트
            Button {
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Text("새로고침")
            }
        }
    }
}

//MARK: - 위젯

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"
    let provider = Provider()
    
    private let supportedFamilies:[WidgetFamily] = {
        if #available(iOSApplicationExtension 16.0, *) { //잠금화면 위젯은 iOS16부터
            // iOS 16, 높은 버전 이용자
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular]
        } else {
            // iOS 16, 낮은 버전 이용자
            return [.systemSmall, .systemMedium]
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
