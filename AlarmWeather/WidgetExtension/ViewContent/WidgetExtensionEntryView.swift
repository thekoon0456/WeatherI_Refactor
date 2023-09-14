//
//  WidgetExtensionEntryView.swift
//  WidgetExtension
//
//  Created by Deokhun KIM on 2023/09/14.
//

import Combine
import SwiftUI
import WidgetKit

//MARK: - 위젯에 표시되는 뷰

struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    let data: WidgetData
    var realmData = RealmManager.shared.readUsers()
    
    var body: some View {
        ZStack {
            //배경 이미지
            widgetBackgroundImage
            
            //TODO: - 위젯 크기에 따라 다른 화면 구현
            //내부 날씨 화면
            HStack {
                VStack(alignment: .leading) {
                    Text(data.administrativeArea ?? "앱을 실행해주세요")
                        .font(.footnote)
                    
                    Image(systemName: data.todayWeatherIconName ?? "gobackward")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .padding(.leading, 5)
                    
                    Text(data.todayWeatherLabel ?? "날씨 로딩 실패")
                        .font(.callout)
                        .bold()
                    Text((data.todayTemp ?? "날씨 로딩 실패") + "º")
                        .font(.callout)
                        .bold()
                    if data.todayPop != "0" {
                        Text("강수 확률: " + (data.todayPop ?? "날씨 로딩 실패") + "%")
                            .font(.footnote)
                    }
                    
                    //테스트 (업데이트 시간 확인)
//                    Text(getTime()).font(.system(.footnote))
                }
                .foregroundColor(.white)
                .padding(5)
//                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .padding(7)
                
                Spacer()
            }
            
        }
        
    }
}

//MARK: -  Widget View

extension WidgetExtensionEntryView {
    var widgetBackgroundImage: some View {
        var backgroundImage: Image
        
        if let realmImage = realmData.first?.alertImage,
           let image = resizeImage(image: UIImage(data: realmImage),
                                   targetSize: CGSize(width: 400, height: 400)) {
            backgroundImage = Image(uiImage: image)
        } else {
            let image = resizeImage(image: UIImage(named: data.todayBackgroundImage ?? "cloudy1"),
                                    targetSize: CGSize(width: 400, height: 400))
            backgroundImage = Image(uiImage: image ?? UIImage())
        }
        
        return backgroundImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .padding(-1) //오른쪽 모서리 흰줄
            .overlay {
                Rectangle().foregroundColor(Color.black.opacity(0.2))
            }
    }
}

//MARK: - TestCode

extension WidgetExtensionEntryView {
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "mm/dd hh:mm:ss"
        return dateFormatter.string(from: data.updateTime ?? Date())
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
