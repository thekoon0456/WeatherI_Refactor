//
//  WidgetView.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/12.
//

import Combine
import SwiftUI
import WidgetKit

//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry
    var imageURLString = UserDefaults.shared.string(forKey: "imageURLString")
    
    var body: some View {
        ZStack {
            //TODO: - 배경이미지 설정 (현재 로컬 URL 못 받아오는 중)
            if let imageURLString = entry.imageURL,
               let imageUrl = URL(string: imageURLString) {
                // Image 뷰를 사용하여 로컬 이미지 표시
                Image(uiImage: loadImage(from: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                let randomInt = (1...5).randomElement()!
                let originalImage = UIImage(named: "sunnyNight" + "\(randomInt)")
                let image = resizeImage(image: originalImage!,
                                        targetSize: CGSize(width: 500, height: 500))
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
