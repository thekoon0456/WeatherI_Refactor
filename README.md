# 🌤️ 날씨의 i
`사용자가 설정한 시간에 나만의 기상캐스터가 오늘의 날씨를 알려주고, 바탕화면에 위젯을 추가할 수 있는 날씨 앱입니다.` <br>
`개인 프로젝트, 2.1.1 업데이트 (UIKit, SwiftUI, MVVM)` <br>

> 매일 외출하는 시간에 가족, 연인, 최애가 오늘의 날씨를 알려드려요!<br>
> 🌤️ 날씨의 i 와 함께 하는 장마철. 우산도 잊지 말고 챙겨요:)<br>
> 기상청 서버와 실시간으로 통신해서 정확한 날씨를 가져옵니다.<br>
<br>

## 🔗 Links
### [📱 AppStore](https://bit.ly/AppStore_WeatherI)
### [💻 GitHub](https://github.com/thekoon0456/WeatherI_Refactor)
### [👨‍💻 Blog](https://thekoon0456.tistory.com/search/날씨)
<br>

## 🧑🏻‍💻 핵심 키워드

![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=UIKit&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=Swift&logoColor=blue)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)

![Realm](https://img.shields.io/badge/realm-39477F?style=for-the-badge&logo=Realm&logoColor=white)
![SnapKit](https://img.shields.io/badge/SnapKit-4285F4?style=for-the-badge&logo=SnapKit&logoColor=white)
![NotificationContentsExtension](https://img.shields.io/badge/NotificationContentsExtension-000000?style=for-the-badge&logo=NotificationContentsExtension&logoColor=white)
<br>
<br>

## 📌 주요 기능
- 기상청, 에어코리아 공공데이터 API 연동: 단기 예보조회, 중기 육상 예보 조회, 중기 기온 조회, 시도별 미세먼지 실시간 평균 정보 조회. 총 4가지 API 동시 처리
- 한 눈에 들어오는 날씨 데이터: 현재 날씨, 미세먼지 상태, 상세 날씨, 시간별 날씨, 주간 날씨 등 다양한 날씨정보 제공
- 아름다운 배경화면: 날씨, 시간에 따라 어울리는 다양한 배경화면 제공
- 알림 기능: NotificationContentsExtension를 활용해 유저가 설정한 시간에 오늘의 날씨정보를 제공
- 커스텀 알림 뷰: 사용자가 좋아하는 사람을 날씨요정으로 설정하고, 사진과 함께 날씨데이터를 받음
- 날씨 아이템 추천: 우산, 모자, 선크림 등 오늘 날씨에 필요한 아이템 추천
- 데이터 새로고침: 앱이 background에서 다시 foreground로 진입 시 자동으로 데이터 새로고침, 아래로 당겨 유저가 원할 때 수동으로 새로고침 가능
- 애니메이션 뷰: 온 보딩, 로딩 화면 등 로티를 활용한 다양한 애니메이션 뷰 제공 
<br>

## 📱시연 영상
|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/e2310b70-0b10-4c95-b161-731807d37950"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/87b36b00-853f-4ee3-843d-70c24fe81649"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/a0107164-28f7-416d-863a-2241aa12e7c3"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/fd86103e-c18d-4338-9d34-41dcbf62aff8"></img>|
|:-:|:-:|:-:|:-:|
|`알림 뷰`|`메인 뷰`|`위젯 뷰`|`온보딩 뷰`|
|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/e863ab80-ea5a-43c9-a999-19d638d2a5c3"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/fd86103e-c18d-4338-9d34-41dcbf62aff8"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/d031ed7e-d037-4267-992e-ddca6cf91cb4"></img>|<img src="https://github.com/thekoon0456/WeatherI_Refactor/assets/106993057/bddfaf18-1453-4b21-8d60-5e000e247be9"></img>|
|`설정 뷰`|`웹, 메일 뷰`|`꾸준한 업데이트`|`긍정적 리뷰`|
<br>

## ✅ 트러블 슈팅
### 날씨 API 채택하기
<div markdown="1">
        
```
Apple의 WeatherKit과 기상청 API를 비교하고, 기상청 API를 채택했습니다.

Apple WeatherKit는 편리했습니다.
Apple이 만들어놓은 API를 직접 사용하고, 전 세계에서 사용 가능하다는 장점이 있었지만,
사용하는 날씨 데이터가 한국에서 사용하는 기상청의 데이터와 조금씩 달랐습니다. 

반면에 기상청의 API는 적용하기에 불편한 면이 있었습니다.
오늘의 날씨, 미세먼지, 주간 온도, 주간 날씨 등 네 가지의 다른 API를 사용해야 했고, 추가적인 데이터 가공도 많이 필요했습니다.
저는 다양한 데이터를 처리하고 가공하며 기술적인 역량을 늘리기 위해 불친절하지만 보편적인 기상청 API를 채택했습니다.
```

```swift
//오늘의 날씨 데이터를 URLSession으로 불러오는 메서드

func performRequest<T>(completion: @escaping (Result<[T], NetworkError>) -> (Void)) {
    setNxNy(nx: LocationService.shared.latitude ?? 0, ny: LocationService.shared.longitude ?? 0)
    guard let url = URL(string: weatherURL) else { return }
    
    let session = setCustomURLSession(retryRequest: DoubleConstant.networkRequest.rawValue)
    session.dataTask(with: url) { [weak self] data, response, error in
        guard let self else { return }
        if error != nil {
            print("네트워크 에러 \(String(describing: error?.localizedDescription))")
            completion(.failure(.networkingError))
            retryRequest(completion: completion)
            return
        }
            
        guard let data = data else {
            print("데이터 에러")
            completion(.failure(.dataError))
            retryRequest(completion: completion)
            return
        }

        if let item = parseWeatherJSON(data) as? [T] {
            print("Weather JSON 파싱 성공")
            completion(.success(item))
        } else {
            retryRequest(completion: completion)
            completion(.failure(.parseError))
        }
    }.resume()
}
```
</div>
<br>

### 사용자의 위치를 파악하고, 현재 위치의 날씨 요청
<div markdown="1">
        
```
CoreLocation을 활용해 사용자의 현재 위, 경도를 파악하고, 파악한 좌표를 바탕으로 기상청 서버에 쿼리를 요청했습니다.

LocationService를 싱글톤으로 만들어 앱 진입 시점에서 사용자의 위, 경도를 얻어오고, 이를 바탕으로 데이터를 요청했습니다. 
하지만 날씨 데이터가 정확하지 않았고, CoreLocation에서 구한 위, 경도를 기상청에서 사용하는 독자적인 X, Y좌표로 변환한 후에 정확한 데이터를 받아올 수 있었습니다. 

또한 CLGeocoder()의 placemarks를 요청해 앱에서 화면에 표시할 주소를 가져왔는데, 구 주소와 도로명 주소가 랜덤하게 가져와져서 두 가지 경우를 모두 고려해 주소를 가져오도록 만들었습니다.
```

```swift
// 기상청 좌표와 주소를 구해오는 코드

func locationToString(location: CLLocation, completion: @escaping () -> (Void)) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(
        location,
        preferredLocale: self.locale
    ) { [weak self] placemarks, _ in
        guard
            let self = self,
            let placemarks = placemarks
        else { return }
        print("DEBUG: 현재 위치는 \(location)입니다.")
        
        //주소가 구 주소일때
        if let locality = placemarks.last?.locality,
            let subLocality =  placemarks.last?.subLocality,
            let administrative = placemarks.last?.administrativeArea {
            userRegion = locality + " " + subLocality
            localityRegion = locality
            subLocalityRegion = subLocality
            administrativeArea = administrative
            print("DEBUG: 현재 주소는 구 주소: \(String(describing: userRegion))입니다.")
        }
        
        //주소가 도로명 주소일때
        if let administrative = placemarks.first?.administrativeArea,
            let name = placemarks.first?.name {
            userRegion = administrative + " " + name
            administrativeArea = administrative
            print("DEBUG: 현재 주소는 도로명: \(String(describing: userRegion))입니다.")
        }
        
        // 가져온 위, 경도를 기상청의 x, y 좌표로 변환
        let convertedXy = LocationService.shared.convertGRID_GPS(lat_X: latitude ?? 0, lng_Y: longitude ?? 0)
        convertedX = convertedXy.x
        convertedY = convertedXy.y
        print("converted: \(convertedX), \(convertedY)")
        
        //MARK: - Widget에 보내주는 데이터들
        UserDefaults.shared.set(convertedX, forKey: "convertedX")
        UserDefaults.shared.set(convertedY, forKey: "convertedY")
        UserDefaults.shared.set(administrativeArea, forKey: "administrativeArea")
        completion()
    }
}
```
</div>
<br>

### 데이터 로딩 화면, 온 보딩 화면에서 애니메이션 실행
<div markdown="1">
        
```
앱을 처음 설치하고 온 보딩 뷰를 사용하거나, 데이터를 가져오는 동안 사용자의 시작적인 즐거움을 위해 Lottie를 적용했습니다.
네 가지의 다른 API를 동시에 가져오기 위해 DispatchGroup을 사용했으며
completion이 되기 전까지 Lottie Animation을 실행되도록 구성했습니다.
```

```swift
//각기 다른 API 호출하고, 완료되면 Lottie Animation 종료

func loadData(completion: @escaping () -> Void) {
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    viewModel.loadTodayWeather { [weak self] model in
        guard let self = self else { return }
        todayWeather = model
        print("DEBUG: loadTodayWeather 완료")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    viewModel.loadTodayDetailWeather { [weak self] model in
        guard let self = self else { return }
        todayDetailWeather = model
        print("DEBUG: loadTodayDetailWeather 완료")
        dispatchGroup.leave()
    }
        
    dispatchGroup.enter()
    dustViewModel.loadTodayDust { [weak self] model in
        guard let self = self else { return }
        todayDust = model
        print("DEBUG: loadTodayDust 완료")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    viewModel.loadWeeklyWeather { [weak self] model in
        guard let self = self else { return }
        weeklyWeather = model
        print("DEBUG: loadWeeklyWeather 완료")
        dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    viewModel.loadWeeklyWeatherTemp { [weak self] model in
        guard let self = self else { return }
        weeklyWeatherTemp = model
        print("DEBUG: loadWeeklyWeatherTemp 완료")
        dispatchGroup.leave()
    }
    
    dispatchGroup.notify(queue: .main) {
        print("DEBUG: loadData완료")
        
        //Lottie 애니메이션 종료
        completion()
    }
}
```
</div>
<br>

### 로컬 알림으로 사용자에게 알림을 보내면서 서버와 통신한 데이터를 가져올 수 없는 문제
<div markdown="1">
        
```
백엔드 서버를 따로 사용할 수 없는 환경이었기 때문에 로컬 알림으로 오늘 날씨 알림을 구현해야 했습니다.
로컬 알림에서 사용자가 알림을 받는 시점에서 서버와 통신한 최신 데이터를 가져올 수 없기 때문에
App에서 날씨 알림을 등록할 때 UNCalendarNotificationTrigger와 UNMutableNotificationContent를 활용해 알림을 설정한 시간에 트리거를 보내고,
NotificationContentsExtension를 활용해서 알림을 꾹 눌렀을 때 서버에 날씨를 요청하도록 커스텀 알림 화면을 구현했습니다.
```

```swift
//UNNotification을 받아 알림 화면에 구현하는 코드

func didReceive(_ notification: UNNotification) {
    
    //이미지가 있으면 이미지를, 없으면 기본 이미지를 알림창에 표시
    if let image = realmData.first?.alertImage {
        profileImageView.image = UIImage(data: image)
    } else {
        profileImageView.image = defaultImage()
    }
    
    guard
        let userInfo = notification.request.content.userInfo as? [String: Any],
        let alertName = userInfo["alertName"] as? String
    else { return }
    
    //데이터를 요청
    loadData { [weak self] in
        guard let self = self else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            //데이터 요청이 완료되면 UI를 구성하고, Animation 종료합니다.
            updateUI(userName: alertName)
            stopAnimation()
        }
    }
}
```
</div>
<br>

### SwiftUI로 Widget구성하고, 백그라운드에서 서버에 주기적으로 API 요청
<div markdown="1">
        
```
날씨 앱을 기획할 때부터 위젯은 필수로 구현하기로 생각했었습니다.
SwiftUI의 WidgetKit으로 위젯을 구현하고, 백그라운드에서 서버와 통신을 하고 화면을 새로 고칠 수 있도록 구현해야 했습니다.
getData 메서드로 서버에 데이터를 요청하고 widgetData를 받아와 위젯 화면에 필요한 viewModel을 만들고
getTimeline 함수 내에서 nextRefresh를 만들어 1시간마다 주기적으로 업데이트할 수 있도록 구현했습니다.
```

```swift
//1시간에 1번씩 서버에 데이터를 요청하고 받아온 데이터로 위젯 업데이트

func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
    getData { [weak self] widgetData in
        guard let self else { return }
        
        let todayWeatherLabel = getTodayState(model: widgetData)
        let todayWeatherIconName = getTodayIconName(model: widgetData)
        let todayTemp = getTemp(model: widgetData)
        let todayPop = getPop(model: widgetData)
        let todayBackgroundImage = getHomeViewBackgroundImage(model: widgetData)
        
        var widgetViewModel = WidgetViewModl(todayWeatherLabel: todayWeatherLabel,
                                            todayWeatherIconName: todayWeatherIconName,
                                            todayTemp: todayTemp,
                                            todayPop: todayPop,
                                            todayBackgroundImage: todayBackgroundImage)
    
        let currentDate = Date()
        let nextRefresh = Calendar.current.date(byAdding: .hour,
                                                value: 1,
                                                to: currentDate) ?? Date()
        
        let entry = WeatherEntr(date: currentDate,
                                data: widgetViewModel)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        print("DEBUG: timeline: \(timeline)")
        completion(timeline)
    }
}
```
</div>
<br>

### 데이터를 CRUD하고 AppExtension에서도 동일한 데이터 활용하기
<div markdown="1">
        
```
realm 라이브러리를 활용해서 앱의 CRUD를 구현하고, 마이그레이션을 통해 여러 AppExtension에서 활용했습니다.

프로토타입에서는 Apple의 프레임워크인 CoreData를 활용해서 CRUD를 구현했지만, 복잡한 데이터를 다루기에 불편함이 있어 realm으로 리팩토링해 CRUD를 구현했습니다.
커스텀 알림과 위젯을 구현하면서 AppExtension인 NotificationContentsExtension과 WidgetExtension에서 데이터에 접근할 수 없는 문제가 있었는데 
realm에서 저장한 데이터를 AppDelegate에서 RealmContainer로 만들어서 AppExtension에서도 동일한 데이터를 접근해서 사용할 수 있도록 구현했습니다.
```

```swift
//RealmContainer를 만들어서 다양한 AppExtension에서 접근 가능하도록 구현

func setRealmContainer() {
    let defaultRealm = Realm.Configuration.defaultConfiguration.fileURL!
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.weatherI.widget")
    let realmURL = container?.appendingPathComponent("default.realm")
    var config: Realm.Configuration!
    
    if FileManager.default.fileExists(atPath: defaultRealm.path) {
        do {
            _ = try FileManager.default.replaceItemAt(realmURL!, withItemAt: defaultRealm)
            config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        } catch {
            print("DEBUG: Error setRealmContainer: \(error)")
        }
    } else {
        config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
    }
    
    Realm.Configuration.defaultConfiguration = config
}
```
</div>
<br>

### 사용자가 여러 사진을 설정하면 앱에서는 사진이 삭제되지만 시스템 폴더에 계속 용량이 쌓이는 문제
<div markdown="1">
        
```
Notification과 Widget에서 사용자가 여러 사진을 설정하면 앱 내에서는 기존의 사진을 삭제하고 새로운 사진으로 대체했지만
시스템 폴더의 TEMP 폴더에 기존의 사진이 계속 쌓여서 불필요하게 앱의 용량이 늘어나는 문제가 있었습니다.

FileManager와 NSTemporaryDirectory를 활용해서 앱을 종료할 때마다 TEMP 폴더에 있는 사진을 삭제하도록 구현했고
 불필요하게 앱의 용량이 커지는 문제를 해결할 수 있었습니다.
```

```swift
//앱 종료시 임시파일 삭제 메서드

func deleteFilesInTmpDirectory() {
    let fileManager = FileManager.default
    let tmpDirectory = NSTemporaryDirectory()
    
    do {
        let tmpContents = try fileManager.contentsOfDirectory(atPath: tmpDirectory)
        for file in tmpContents {
            let filePath = (tmpDirectory as NSString).appendingPathComponent(file)
            try fileManager.removeItem(atPath: filePath)
            print("삭제된 임시 파일: \(filePath)")
        }
    } catch {
        print("DEBUG: TMP 폴더 삭제 Error - \(error.localizedDescription)")
    }
}

// 앱 종료시 SceneDelegate에서 위젯 업데이트와 임시파일 삭제

func sceneWillResignActive(_ scene: UIScene) {
    // 위젯 업데이트 요청 보내기
    WidgetCenter.shared.reloadTimelines(ofKind: "com.thekoon.NotiWeather")
        
    // 앱 종료시 임시파일 삭제
    deleteFilesInTmpDirectory()
}
```
</div>
<br>

## 📂 폴더 트리
<details>
<summary>폴더 트리 열어보기 </summary>
<div markdown=“1”>
<pre>
// MVVM 패턴의 구조에 따라 Entity -> Respository -> Models -> Service -> ViewModels -> Views 의 단방향 데이터 흐름 구현

AlarmWeather/
├─ AppDelegate.swift
├─ SceneDelegate.swift
├─ ScaledImage.swift
├─ 📂 Entity/
│  ├─ WeatherEntity.swift
│  ├─ WeeklyWeatherEntity.swift
│  ├─ WeeklyWeatherTempEntity.swift
│  ├─ DustEntity.swift
│  ├─ HomeView.swift
│  └─ UserEntity.swift
│  
├─ 📂 Respository/
│  ├─ WeatherRepository.swift
│  ├─ WeeklyWeatherRepository.swift
│  ├─ WeeklyWeatherTempRepository.swift
│  └─ DustRepository.swift
│  
├─ 📂 Models/
│  ├─ WeatherModel.swift
│  ├─ WeeklyWeatherModel.swift
│  ├─ WeeklyWeatherTempModel.swift
│  └─ DustModel.swift
│  
├─ 📂 Service/
│  ├─ WeatherService.swift
│  ├─ WeeklyWeatherService.swift
│  ├─ WeeklyWeatherTempService.swift
│  ├─ DustService.swift
│  ├─ UserService.swift
│  ├─ LocationService.swift
│  └─ AlertService.swift
│  
├─ 📂 ViewModels/
│  ├─ HomeViewModel.swift
│  ├─ DustViewModel.swift
│  ├─ SettingProfileViewModel.swift
│  └─ TextFieldViewModel.swift
│ 
├─ 📂 Views/
│  ├─ WetherAndDustStackView.swift
│  ├─ TodayWeatherCell.swift
│  ├─ TodayDetailWeatherCell.swift
│  ├─ WeeklyWeatherCell.swift
│  ├─ SettingCell.swift
│  ├─ AlertTimeCell.swift
│  ├─ CustomTextField.swift
│  └─ SaveButton.swift
│  
├─ 📂 Controllers/
│  ├─ OnboardingViewController.swift
│  ├─ OnboardingContentViewController.swift
│  ├─ RootViewController.swift
│  ├─ HomeController.swift
│  ├─ WeatherController.swift
│  ├─ DustController.swift
│  ├─ SettingController.swift
│  ├─ UpdateSettingViewController.swift
│  └─ SettingAddAlertViewController.swift
│  
├─ 📂 Utils/
│  ├─ Constant.swift
│  └── Extention.swift
│  ├─ 📂 Lottie/
│  │  └─ loading.json
│  │  └─ location.json
│  │  └─ addUser.json
│  └──── notification.json
│  
└── 📂 NotificationContentsExtension/
└── 📂 WidgetExtension/
</pre>
</div>
</details>
<br>

## 💻 앱 개발 환경

- 최소 지원 버전: iOS 15.0+
- Xcode Version 14.3.1 (14E300c)
- iPhone 14 Pro, iPhone 14 Pro + 에서 최적화됨, iPhone SE3까지 호환 가능
- 다크모드 지원, 가로모드 미지원
<br>
