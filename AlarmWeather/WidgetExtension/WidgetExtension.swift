//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/04.
//

import Combine
import SwiftUI
import WidgetKit

//MARK: - TimelineProvider
/*
 위젯의 업데이트할 시기를 WidgetKit에 알려줌.
 WidgetKit이 Provider에 업데이트 할 시간, TimeLine을 요청
 요청을 받은 Provider는 TimeLine을 WidgetKit에 제공
 */



//MARK: - TimelineEntry
/*
 TimelineEntry는 date 라는 필수 프로퍼티를 가지는 프로토콜.
 이 date는 위젯을 업데이트하는 시간.
 위젯을 업데이트하는데 기준이 되는 시간과, 위젯에 표시할 컨텐츠를 설정합니다.
 */

struct WeatherEntry: TimelineEntry {
    let date: Date //시간
    var imageURL: String?
    var administrativeArea = UserDefaults.shared.string(forKey: "administrativeArea") ?? "위치 인식 실패" //위치
    var todayWeather: [Item]? //기상청 서버에서 가져온 [Item]
    var todayWeatherLabel: String? //날씨 상태
    var todayWeatherIconName: String? //날씨 아이콘
    var todayTemp: String? //온도
    var todayPop: String? //강수확률
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
        return resizeImage(image: originalImage!, targetSize: CGSize(width: 600, height: 600))
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
