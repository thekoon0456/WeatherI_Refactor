//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/04.
//

import SwiftUI
import WidgetKit

//MARK: - 위젯

struct WidgetExtension: Widget {
    let kind: String = "com.thekoon.NotiWeather.WidgetExtension" //위젯 고유 키
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider()) { entry in
            WidgetExtensionEntryView(data: entry.data)
        }
        .configurationDisplayName("날씨의 i") //위젯 추가시 디스플레이에 표시되는 앱 이름
        .description("현재 위치의 오늘의 날씨를 확인하세요") //앱 설명
        .supportedFamilies(supportedFamilies) //위젯 사이즈
        // MARK: - 위젯 추가 패딩 삭제
        .contentMarginsDisabled()
    }
}


//MARK: - 잠금화면 위젯 설정
 
extension WidgetExtension {
    private var supportedFamilies:[WidgetFamily] {
//        if #available(iOSApplicationExtension 16.0, *) { //잠금화면 위젯은 iOS16부터
//            // iOS 16, 높은 버전 이용자 (잠금화면 위젯)
//            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular]
//        } else {
            // iOS 16, 낮은 버전 이용자
            return [.systemSmall, .systemMedium, .systemLarge]
//        }
    }
}
