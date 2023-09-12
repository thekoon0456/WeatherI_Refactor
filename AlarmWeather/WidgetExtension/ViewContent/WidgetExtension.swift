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
    var entry: Provider.Entry
    var imageURLString = UserDefaults.shared.string(forKey: "imageURLString")
    
    var body: some View {
        ZStack {
            //            //TODO: - 배경이미지 설정 (현재 로컬 URL 못 받아오는 중)
            //            if let imageURLString = entry.imageURL,
            //               let imageUrl = URL(string: imageURLString) {
            //                // Image 뷰를 사용하여 로컬 이미지 표시
            //                Image(uiImage: loadImage(from: imageUrl))
            //                    .resizable()
            //                    .aspectRatio(contentMode: .fill)
            //            } else {
            let image = resizeImage(image: UIImage(named: entry.todayBackgroundImage ?? ""),
                                    targetSize: CGSize(width: 500, height: 500))
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            //            }
            
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
        let randomInt = (1...5).randomElement() ?? 1
        let originalImage = UIImage(named: "sunnyNight" + "\(randomInt)")
        return resizeImage(image: originalImage!, targetSize: CGSize(width: 600, height: 600))
    }
    
    //파일 사이즈 변경 함수
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage {
        guard let size = image?.size else { return UIImage(named: "sunnyNight1") ?? UIImage()}
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

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        WidgetExtensionEntryView(entry: WeatherEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
