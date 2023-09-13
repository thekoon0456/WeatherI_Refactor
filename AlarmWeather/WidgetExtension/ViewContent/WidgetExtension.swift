//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/04.
//

import Combine
import SwiftUI
import WidgetKit

//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    let data: WidgetData
    var realmData = RealmManager.shared.readUsers()
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "mm/dd hh:mm:ss"
        return dateFormatter.string(from: data.updateTime ?? Date())
    }
    
    
    var body: some View {
        ZStack {
            if let image = resizeImage(image: UIImage(data: realmData.first?.alertImage ?? Data()),
                                       targetSize: CGSize(width: 400, height: 400)) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(-1) //오른쪽 모서리 흰줄
                    .overlay {
                        Rectangle().foregroundColor(Color.black.opacity(0.2))
                    }
            } else {
                Image(systemName: data.todayBackgroundImage ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(-1) //오른쪽 모서리 흰줄
                    .overlay {
                        Rectangle().foregroundColor(Color.black.opacity(0.2))
                    }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(data.administrativeArea)
                        .font(.system(.footnote))
                    
                    Image(systemName: data.todayWeatherIconName ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .padding(.leading, 5)
                    
                    Text(data.todayWeatherLabel ?? "날씨 로딩 실패")
                        .font(.system(.callout, weight: .bold))
                    Text((data.todayTemp ?? "날씨 로딩 실패") + "º")
                        .font(.system(.callout, weight: .bold))
                    if data.todayPop != "0" {
                        Text("강수 확률: " + (data.todayPop ?? "날씨 로딩 실패") + "%")
                            .font(.system(.footnote))
                    }
                    
                    Text(getTime()).font(.system(.footnote))
                    
                }
                .foregroundColor(.white)
//                .padding(5)
//                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .padding(7)
                
                Spacer()
            }
            
        }

    }
}

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
    //파일 사이즈 변경 함수
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let size = image?.size else { return UIImage()}
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
        image?.draw(in: CGRect(origin: .zero, size: newSize))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage(named: "sunnyNight1") ?? UIImage()
        }
        UIGraphicsEndImageContext()

        return newImage
    }
}

//struct WidgetExtension_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetExtensionEntryView(data: WidgetData())
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
