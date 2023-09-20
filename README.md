# 🌤️ 날씨의 i
2.0 리팩토링!(UIKit, MVVM, RxSwift, WidgetKit)<br>
매일 외출하는 시간에 가족, 연인, 최애가 오늘의 날씨를 알려드려요!<br>
🌤️ 날씨의 i 와 함께 하는 장마철. 우산도 잊지 말고 챙겨요:)<br>
기상청 서버와 실시간으로 통신해서 정확한 날씨를 가져옵니다.
<br>
<br>

## 🔗 앱 스토어 다운로드 링크
👉🏻 [앱 스토어에서 날씨의 i 다운로드하기](https://apps.apple.com/app/%EB%82%A0%EC%94%A8%EC%9D%98-i/id6458547520)<br>
👉🏻 [날씨의 i 노션 페이지 방문하기](https://bit.ly/weatherI)
<br>
<br>

## 🧑🏻‍💻 핵심 키워드

![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=UIKit&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)

![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)
![Realm](https://img.shields.io/badge/realm-39477F?style=for-the-badge&logo=Realm&logoColor=white)
![SnapKit](https://img.shields.io/badge/SnapKit-4285F4?style=for-the-badge&logo=SnapKit&logoColor=white)
![NotificationContentsExtension](https://img.shields.io/badge/NotificationContentsExtension-000000?style=for-the-badge&logo=NotificationContentsExtension&logoColor=white)
<br>
<br>

## 📌 주요 기능
- 기상청, 에어코리아 공공데이터 API 연동: 단기예보조회, 중기육상예보조회, 중기기온조회, 시도별 미세먼지 실시간 평균정보 조회. 총 4가지 API 동시 처리
- 한 눈에 들어오늘 날씨 데이터: 현재 날씨, 미세먼지 상태, 상세 날씨, 시간별 날씨, 주간 날씨 등 다양한 날씨정보 제공
- 아름다운 배경화면: 날씨, 시간에 따라 어울리는 다양한 배경화면 제공
- 알림 기능: NotificationContentsExtension를 활용해 유저가 설정한 시간에 오늘의 날씨정보를 제공
- 커스텀 알림 뷰: 사용자가 좋아하는 사람을 날씨요정으로 설정하고, 사진과 함께 날씨데이터를 받음
- 날씨 아이템 추천: 우산, 모자, 선크림 등 오늘 날씨에 필요한 아이템 추천
- 데이터 새로고침: 앱이 background에서 다시 foreground로 진입시 자동으로 데이터 새로고침, 아래로 당겨 유저가 원할때 수동으로 새로고침 가능
- 애니메이션 뷰: 온보딩, 로딩화면 등 로티를 활용한 다양한 애니메이션 뷰 제공 
<br>

## 📱시연 영상
|<img src="https://github.com/thekoon0456/WeatherI/assets/106993057/e1bb7999-bf0f-4772-85e4-f59359ffb8c2"></img>|<img src="https://github.com/thekoon0456/WeatherI/assets/106993057/dae01aa5-0718-4967-99ca-d3d7c4a896de"></img>|<img src="https://github.com/thekoon0456/WeatherI/assets/106993057/a5752520-fe81-4297-a212-0714ba47c654"></img>|<img src="https://github.com/thekoon0456/WeatherI/assets/106993057/71612a3b-3142-4f39-9797-80ec02c0c9a6"></img>|
|:-:|:-:|:-:|:-:|
|`알림 뷰`|`메인 뷰`|`설정 뷰`|`온보딩 뷰`|
<br>

## ✌️ 트러블 슈팅
👉🏻 [블로그에서 험난한 트러블슈팅 과정 보기](https://thekoon0456.tistory.com/category/UIKit%20Project)
- WeatherKit과 기상청 API 비교 후 정확한 날씨데이터 적용하는 과정
- CoreLocation을 활용해 사용자의 위, 경도를 파악한 뒤, API에 요청해서 위치에 맞는 날씨데이터 가져오기
- CoreLocation을 활용해 데이터를 가져왔지만, 날씨가 정확하지 않았고, 위,경도를 기상청에서 사용하는 X,Y좌표로 변환해 정확한 기상청 데이터 가져오기
- 4개의 API를 비동기로 호출하고 데이터를 가져오는 동안 Lottie 애니메이션 뷰 실행, 모든 데이터를 받아오고 UI를 구성한 뒤 Lottie뷰를 종료시키기 위해서는?
- 데이터를 저장하는 과정에서 CoreData로 CRUD를 구현했지만, 커스텀 타입을 다루기 어려웠고, realm으로 리팩토링한 과정
- 로컬 알림으로 사용자에게 알림을 보내면서 서버와 통신한 데이터를 가져올 수 없는 치명적인 문제 발생 - NotificationContentsExtension 활용해서 커스텀 알림 구현
- NotificationContentsExtension으로 사용자에게 전송할 사진을 변경할때 사진이 삭제되지 않고 로컬 저장공간에 계속 쌓이는 문제 해결
- background에서 foreground로 진입시 자동으로 메인 뷰에 진입하고, 데이터 업데이트도 하려면?
- 출시하면서 세 번의 리젝 사유와 AppCrash 문제 해결, 앱 출시까지!
<br>

## 📂 폴더 트리
<details>
<summary>폴더 트리 열어보기 </summary>
<div markdown=“1”>
<pre>
MVVM 패턴의 구조에 따라 Entity -> Respository -> Models -> Service -> ViewModels -> Views 의 단방향 데이터 흐름 구현
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

 ## 🔗 포트폴리오 링크
👉🏻 [제작자의 포트폴리오 보고 인재 영입하기](https://bit.ly/thekoonPortfolio)
<br>
