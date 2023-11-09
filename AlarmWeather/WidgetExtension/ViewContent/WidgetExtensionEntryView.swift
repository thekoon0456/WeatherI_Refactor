//
//  WidgetExtensionEntryView.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/14.
//

import SwiftUI
import WidgetKit

//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var data: WidgetViewModel
    var realmData = WidgetRealmManager.shared.readUsers()
    
    var body: some View {
        ZStack {
            //내부 날씨 화면
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        administrativeAreaLabel
                        todayWeatherIcon
                        todayWeatherLabel
                        todayTempLabel
                        todayPopLabel
                        // timeTestLabel
                    }
                    .foregroundColor(.white)
                    .padding(10)
                    
                    Spacer()
                }
                largeSizeSpacer //위젯 사이즈 .large일때 spacer
            }
        }
        .widgetBackground(backgroundView: resizedBGImage)
    }
}

#Preview {
    WidgetExtensionEntryView(data: WidgetViewModel())
}

//MARK: -  Widget View

extension WidgetExtensionEntryView {
    var widgetBackgroundImage: Image {
        var backgroundImage: Image
        
        guard
            let imageData = realmData.first?.alertImage,
            let resizedImage = UIImage(data: imageData)?.jpegData(compressionQuality: 0.4),
            let uiImage =  UIImage(data: resizedImage)
        else {
            return Image(data.todayBackgroundImage ?? "sunny1")
        }
        
        backgroundImage = Image(uiImage: uiImage)
        return backgroundImage
    }
    
    var resizedBGImage: some View {
        widgetBackgroundImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.3))
            }
    }
    
    var todayWeatherIcon: some View {
        Image(systemName: data.todayWeatherIconName ?? "gobackward")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
    }
    
    var administrativeAreaLabel: some View {
        Text(data.administrativeArea ?? "앱을 실행해주세요")
            .font(.caption2)
    }
    
    var todayWeatherLabel: some View {
        Text(data.todayWeatherLabel ?? "날씨 로딩 실패")
            .font(.body)
            .bold()
    }

    var todayTempLabel: some View {
        Text((data.todayTemp ?? "온도 로딩 실패") + "º")
            .font(.callout)
            .bold()
    }
    
    var todayPopLabel: Text? {
        if data.todayPop != "0" {
            return Text("강수 확률: " + (data.todayPop ?? "날씨 로딩 실패") + "%")
                .font(.caption)
        }
        
        return nil
    }
//    
//    var timeTestLabel: some View {
//        Text(getTime())
//            .font(.system(size: 10))
//    }
    
    var largeSizeSpacer: Spacer? {
        //위젯 사이즈가 클때 컨텐츠 위로 올림
        if widgetFamily == .systemLarge {
            return Spacer()
        }
        
        return nil
    }
    
}

//MARK: - TestCode
//
extension WidgetExtensionEntryView {
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "MM/dd HH:mm:ss"
        return dateFormatter.string(from: data.updateTime ?? Date())
    }
}

// MARK: - 위젯 백그라운드 뷰 사이즈 조정 함수
extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
