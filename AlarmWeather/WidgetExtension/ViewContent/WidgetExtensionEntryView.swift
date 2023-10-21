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
        GeometryReader { proxy in
            ZStack {
                //배경 이미지
                resizedBGImage
                    .frame(width: proxy.size.width,
                           height: proxy.size.height)
                
                //TODO: - 위젯 크기에 따라 다른 화면 구현
                //내부 날씨 화면
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            administrativeAreaLabel
                            todayWeatherIcon
                            todayWeatherLabel
                            todayTempLabel
                            todayPopLabel
//                            timeTestLabel
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        
                        Spacer()
                    }
            
                    largeSizeSpacer
                }
            }
        }
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
            let realmImage = realmData.first?.alertImage,
            let image = resizeImage(
                image: UIImage(data: realmImage),
                targetSize: CGSize(width: 300, height: 300)
            )
        else {
            let image = resizeImage(
                image: UIImage(named: data.todayBackgroundImage ?? "sunnyNight1"),
                targetSize: CGSize(width: 300, height: 300)
            )
            
            backgroundImage = Image(uiImage: image ?? UIImage())
            return backgroundImage
        }
        
        backgroundImage = Image(uiImage: image)
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
            .padding(-2)
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
    
    var timeTestLabel: some View {
        Text(getTime())
            .font(.system(size: 10))
    }
    
    var largeSizeSpacer: Spacer? {
        //위젯 사이즈가 클때 컨텐츠 위로 올림
        if widgetFamily == .systemLarge {
            return Spacer()
        }
        
        return nil
    }
    
}

//MARK: - Image 관련 extension

extension View {
    //파일 사이즈 변경 함수
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let size = image?.size else { return UIImage() }
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
