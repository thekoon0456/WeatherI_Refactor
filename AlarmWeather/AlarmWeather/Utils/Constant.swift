//
//  Constant.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import UIKit

enum CellId: String {
    case todayDetailWeatherCellId = "todayDetailWeatherCell"
    case todayTimeWeatherCellId = "todayTimeWeatherCell"
    case weeklyWeatherCellId = "WeeklyWeatherCell"
    case alertTimeCell = "alertTimeCell"
    case settingCellId = "settingCellId"
}

enum WeatherModelCount: Int {
    case todayDetailWeatherCount = 30
    case todayOneHourWeatherCount = 12 //오늘 날씨예보 12시간 기준
}

enum DoubleConstant: Double {
    case networkRequest = 7.0
    case loadingDelayMent = 6.0
    case showingLoadingAlert = 25.0
    case updateDataTime = 600 //10분
}

enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
}

enum LottieFiles: String {
    case loadingView = "loading"
    case locationView = "location"
    case addUserView = "addUser"
    case notificationView = "notification"
}

enum WeatherIURL: String {
    case homepage = "https://www.notion.so/thekoon0456/i-ce0ca603f50840f99799338a948acda4"
    case qAndA = "https://www.notion.so/thekoon0456/Q-A-e366265bcdef413f850e7cbe9fdc51fe"
}

/*
 1. 위치, 알림 동의: 현재 위치를 바탕으로 날씨를 받아옵니다. 꼭 동의해주세요.
 2. 설정 -> 유저, 알림 설정: 매일 원하는 시간에 오늘의 날씨 정보와 추천 아이템을 받을 수 있어요!
 3. 알림 기능 처음 사용시 설치 시간이 소요될 수 있습니다. 잠시만 기다려 주세요.
 */

enum Ments: String {
    case weatherI = "날씨의 i"
    case locationView = "안녕하세요☀️\n날씨의 i를 설치해주셔서 감사합니다\n이 앱은 현재 계신 위치의 날씨를 가져옵니다\n꼭 위치와 알림 동의를 해주세요😊"
    case addUserView = "설정에 들어가시면\n유저와 날씨요정의 프로필 설정,\n날씨 알림 받으실 시간을 설정하실 수 있어요😊\n(출근 / 등교시간 10분 전을 추천드려요!)"
    case notificationView = "매일 원하시는 시간에\n설정하신 프로필의 날씨요정이\n오늘 날씨와 추천 날씨 아이템을 알려드려요☀️\n알림창을 짧게 누르면 앱에서,\n꾹 누르면 바로 날씨를 보실 수 있어요😊"
    case loadingMent = "날씨 데이터를 받아오는 중입니다..."
    case loadingDelayMent = "통신이 늦어지네요😅 서버에 재요청 중입니다..."
}

struct NetworkQuery {
    //API_KEY.plist에 키 저장
    static var serviceKey: String {
        guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
            fatalError("Couldn't find file 'API_KEY.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'API_KEY.plist'.")
        }
        
        return value
    }
}

struct CategoryIdentifier {
    static let cumstomUI = "CATEGORY_CUSTOM_UI"
}
struct WeatherMent {
    static let sunArr = ["기분 좋은 맑은 하늘입니다 ☀️",
                         "오늘은 화창한 날씨입니다 ☀️",
                         "맑은 날이니 예쁜 하늘을 보세요 ☀️",
                         "하늘이 맑아서 기분이 좋아지네요 ☀️",
                         "맑은 날 햇살 가득한 하루를 보내세요 ☀️"]
    
    static let cloudArr = ["구름이 많은 하늘입니다 ⛅️",
                           "오늘은 흐린 날씨네요 ⛅️",
                           "구름이 끼어있지만 기분은 화창하기를 ⛅️",
                           "구름이 끼어서 날씨가 안 좋아 보이네요 ⛅️",
                           "흐린 하늘에도 맑은 하루를 보내세요 ⛅️"]
    
    static let cloudSunArr = ["흐린 하늘이지만 마음만은 맑은 날 🌤️",
                              "구름이 무겁게 느껴지는 하루군요 🌤️",
                              "구름이 많아도 햇살처럼 빛나는 하루 되세요 🌤️",
                              "구름이 하늘을 가리지만 태양은 항상 빛나요 🌤️",
                              "흐린 날씨에도 기분 좋은 하루 보내세요 🌤️"]
    
    static let rainArr = ["비가 옵니다. 우산을 챙겨주세요 🌧️",
                          "우산을 꼭 챙기세요. 비가 오네요 🌧️",
                          "비가 내리니 따뜻한 차 한 잔 어떠세요? 🌧️",
                          "비오는 날, 집에서 영화보기 좋아요 🌧️",
                          "비오는 날 집에서 책 읽는건 어떨까요? 🌧️"]
    
    static let rainSnowArr = ["비와 눈이 와요! 우산을 챙겨주세요 ☔️❄️",
                              "비와 눈이 와요. 외출할 때 조심하세요 ☔️❄️",
                              "비와 눈이 와요. 외출 전 꼭 준비하세요 ☔️❄️",
                              "비와 눈이 와요. 따뜻한 음료 어떠세요? ☔️❄️",
                              "비와 눈이 오는 날 ☔️❄️"]
    
    static let snowArr = ["하얀 눈이 와요 ❄️",
                          "하얀 눈이 오네요 ❄️",
                          "눈이 내리네요 ❄️",
                          "하얀 눈이 온 동네는 참 예뻐요 ❄️",
                          "하얀 눈이 내려요! ❄️"]
    
    static let showerArr = ["소나기가 와요! 우산을 챙기세요 ☔️",
                            "소나기가 지나면 더 맑아질 거에요 ☔️",
                            "소나기가 찾아와요 ☔️",
                            "소나기가 시원하게 내려요 ☔️",
                            "소나기로 길이 젖었어요 ☔️"]
}

struct DateAndTime {
    static var currentTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "HH00" //0500
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow)
        return dateFormatter.string(from: dateCreatedAt)
    }
    
    //현재 시간에서 서버 업데이트 시간 전 기준으로 데이터 받아오기
    static var baseTime: String {
        switch currentTime {
        case let time where "2300" <= time && time <= "2359":
            return "2300"
        case let time where "0000" <= time && time < "0200":
            return "2300"
        case let time where "0200" <= time && time < "0500":
            return "0200"
        case let time where "0500" <= time && time < "0800":
            return "0500"
        case let time where "0800" <= time && time < "1100":
            return "0800"
        case let time where "1100" <= time && time < "1400":
            return "1100"
        case let time where "1400" <= time && time < "1700":
            return "1400"
        case let time where "1700" <= time && time < "2000":
            return "1700"
        case let time where "2000" <= time && time < "2300":
            return "2000"
        default:
            return ""
        }
    }

    static var todayDate: String { //오늘 날짜 가져오기. 20230617
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyyMMdd" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow)
        return dateFormatter.string(from: dateCreatedAt)
    }

    static var yesterdayDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyyMMdd" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow - 24 * 60 * 60) //발표 갱신 이전은 어제 발표로
        return dateFormatter.string(from: dateCreatedAt)
    }
    
    static func getLaterDate(afterDate: Int) -> String { //7.14
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "M.dd E" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + (24 * Double(afterDate) * 60 * 60)) //발표 갱신 이전은 어제 발표로
        return dateFormatter.string(from: dateCreatedAt)
    }
    
    static var weeklyQuaryDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyyMMdd0600" // "yyyy-MM-dd HH:mm:ss" //0600시 갱신 기준
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow)
        return dateFormatter.string(from: dateCreatedAt)
    }
    
    static var yesterdayweeklyQuaryDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyyMMdd0600" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow - 24 * 60 * 60) //발표 갱신 이전은 어제 발표로
        return dateFormatter.string(from: dateCreatedAt)
    }
    
    static func getfcstDate(afterTime: Int) -> String { //7.14
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "M.dd E" // "yyyy-MM-dd HH:mm:ss"
        let dateCreatedAt = Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + (Double(afterTime) * 60 * 60))
        return dateFormatter.string(from: dateCreatedAt)
    }
}

struct BackGroundImage {
    static let loadingImage = ["bg1", "bg2", "bg3", "bg4", "bg5", "bg6"]
    static let sunny = ["sunny1", "sunny2", "sunny3", "sunny4", "sunny5", "sunny6"]
    static let sunnyNight = ["sunnyNight1", "sunnyNight2", "sunnyNight3", "sunnyNight4", "sunnyNight5", "sunnyNight6"]
    static let rainy = ["rainy1", "rainy2", "rainy3", "rainy4", "rainy5", "rainy6"]
    static let rainyNight = ["rainyNight1", "rainyNight2", "rainyNight3", "rainyNight4", "rainyNight5", "rainyNight6"]
    static let snowing = ["snowing1", "snowing2", "snowing3", "snowing4", "snowing5", "snowing6"]
    static let snowingNight = ["snowingNight1", "snowingNight2", "snowingNight3", "snowingNight4", "snowingNight5", "snowingNight6"]
    static let cloudy = ["cloudy1", "cloudy2", "cloudy3", "cloudy4", "cloudy5", "cloudy6"]
    static let cloudyNight = ["cloudyNight1", "cloudyNight2", "cloudyNight3", "cloudyNight4", "cloudyNight5", "cloudyNight6"]
}

struct ColorSetting {
    static let color: UIColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
    static let alpha = 1.0
    static let buttonEnabledColor = UIColor(white: 1, alpha: 0.3)
    static let buttonDisabledColor = UIColor(white: 1, alpha: 0.1)
    
}

struct WeeklyWeatherConst {
    //WeeklyWeather 강원도 분기처리
    static let gangwonWest = ["철원", "화천", "양구", "인제", "춘천", "홍천", "횡성", "원주", "평창", "영월", "정선", "이천", "판교", "평강", "세포", "김화", "창도", "회양", "금강"]
    static let gangwonEast = ["강릉", "삼척", "동해", "태백", "속초", "양양", "고성", "통천"]

    //WeeklyWeatherTempRegId
    static let weeklyTempDic = [
        "인천광역시 백령도": "11A00101",
        "서울특별시 서울": "11B10101",
        "경기도 과천": "11B10102",
        "경기도 광명": "11B10103",
        "인천광역시 강화": "11B20101",
        "경기도 김포": "11B20102",
        "인천광역시 인천": "11B20201",
        "경기도 시흥": "11B20202",
        "경기도 안산": "11B20203",
        "경기도 부천": "11B20204",
        "경기도 의정부": "11B20301",
        "경기도 고양": "11B20302",
        "경기도 양주": "11B20304",
        "경기도 파주": "11B20305",
        "경기도 동두천": "11B20401",
        "경기도 연천": "11B20402",
        "경기도 포천": "11B20403",
        "경기도 가평": "11B20404",
        "경기도 구리": "11B20501",
        "경기도 남양주": "11B20502",
        "경기도 양평": "11B20503",
        "경기도 하남": "11B20504",
        "경기도 수원": "11B20601",
        "경기도 안양": "11B20602",
        "경기도 오산": "11B20603",
        "경기도 화성": "11B20604",
        "경기도 성남": "11B20605",
        "경기도 평택": "11B20606",
        "경기도 의왕": "11B20609",
        "경기도 군포": "11B20610",
        "경기도 안성": "11B20611",
        "경기도 용인": "11B20612",
        "경기도 이천": "11B20701",
        "경기도 광주": "11B20702",
        "경기도 여주": "11B20703",
        "충청북도 충주": "11C10101",
        "충청북도 진천": "11C10102",
        "충청북도 음성": "11C10103",
        "충청북도 제천": "11C10201",
        "충청북도 단양": "11C10202",
        "충청북도 청주": "11C10301",
        "충청북도 보은": "11C10302",
        "충청북도 괴산": "11C10303",
        "충청북도 증평": "11C10304",
        "충청북도 추풍령": "11C10401",
        "충청북도 영동": "11C10402",
        "충청북도 옥천": "11C10403",
        "충청남도 서산": "11C20101",
        "충청남도 태안": "11C20102",
        "충청남도 당진": "11C20103",
        "충청남도 홍성": "11C20104",
        "충청남도 보령": "11C20201",
        "충청남도 서천": "11C20202",
        "충청남도 천안": "11C20301",
        "충청남도 아산": "11C20302",
        "충청남도 예산": "11C20303",
        "대전광역시 대전": "11C20401",
        "충청남도 공주": "11C20402",
        "충청남도 계룡": "11C20403",
        "충청남도 세종": "11C20404",
        "충청남도 부여": "11C20501",
        "충청남도 청양": "11C20502",
        "충청남도 금산": "11C20601",
        "충청남도 논산": "11C20602",
        "강원도 철원": "11D10101",
        "강원도 화천": "11D10102",
        "강원도 인제": "11D10201",
        "강원도 양구": "11D10202",
        "강원도 춘천": "11D10301",
        "강원도 홍천": "11D10302",
        "강원도 원주": "11D10401",
        "강원도 횡성": "11D10402",
        "강원도 영월": "11D10501",
        "강원도 정선": "11D10502",
        "강원도 평창": "11D10503",
        "강원도 대관령": "11D20201",
        "강원도 태백": "11D20301",
        "강원도 속초": "11D20401",
        "강원도 고성군": "11D20402",
        "강원도 양양군": "11D20403",
        "강원도 강릉": "11D20501",
        "강원도 동해": "11D20601",
        "강원도 삼척": "11D20602",
        "경상북도 울릉도": "1.10E+102",
        "경상북도 독도": "1.10E+103",
        "전라북도 전주": "11F10201",
        "전라북도 익산": "11F10202",
        "전라북도 정읍": "11F10203",
        "전라북도 완주": "11F10204",
        "전라북도 장수": "11F10301",
        "전라북도 무주": "11F10302",
        "전라북도 진안": "11F10303",
        "전라북도 남원": "11F10401",
        "전라북도 임실": "11F10402",
        "전라북도 순창": "11F10403",
        "전라북도 군산": "21F10501",
        "전라북도 김제": "21F10502",
        "전라북도 고창": "21F10601",
        "전라북도 부안": "21F10602",
        "전라남도 함평": "21F20101",
        "전라남도 영광": "21F20102",
        "전라남도 진도": "21F20201",
        "전라남도 완도": "11F20301",
        "전라남도 해남": "11F20302",
        "전라남도 강진": "11F20303",
        "전라남도 장흥": "11F20304",
        "전라남도 여수": "11F20401",
        "전라남도 광양": "11F20402",
        "전라남도 고흥": "11F20403",
        "전라남도 보성": "11F20404",
        "전라남도 순천시": "11F20405",
        "광주광역시 광주": "11F20501",
        "전라남도 장성": "11F20502",
        "전라남도 나주": "11F20503",
        "전라남도 담양": "11F20504",
        "전라남도 화순": "11F20505",
        "전라남도 구례": "11F20601",
        "전라남도 곡성": "11F20602",
        "전라남도 순천": "11F20603",
        "전라남도 흑산도": "11F20701",
        "전라남도 목포": "21F20801",
        "전라남도 영암": "21F20802",
        "전라남도 신안": "21F20803",
        "전라남도 무안": "21F20804",
        "제주특별자치도 성산": "11G00101",
        "제주특별자치도 제주": "11G00201",
        "제주특별자치도 성판악": "11G00302",
        "제주특별자치도 서귀포": "11G00401",
        "제주특별자치도 고산": "11G00501",
        "제주특별자치도 이어도": "11G00601",
        "제주특별자치도 추자도": "11G00800",
        "제주도 성산": "11G00101",
        "제주도 제주": "11G00201",
        "제주도 성판악": "11G00302",
        "제주도 서귀포": "11G00401",
        "제주도 고산": "11G00501",
        "제주도 이어도": "11G00601",
        "제주도 추자도": "11G00800",
        "경상북도 울진": "11H10101",
        "경상북도 영덕": "11H10102",
        "경상북도 포항": "11H10201",
        "경상북도 경주": "11H10202",
        "경상북도 문경": "11H10301",
        "경상북도 상주": "11H10302",
        "경상북도 예천": "11H10303",
        "경상북도 영주": "11H10401",
        "경상북도 봉화": "11H10402",
        "경상북도 영양": "11H10403",
        "경상북도 안동": "11H10501",
        "경상북도 의성": "11H10502",
        "경상북도 청송": "11H10503",
        "경상북도 김천": "11H10601",
        "경상북도 구미": "11H10602",
        "경상북도 군위": "11H10603",
        "경상북도 고령": "11H10604",
        "경상북도 성주": "11H10605",
        "대구광역시 대구": "11H10701",
        "경상북도 영천": "11H10702",
        "경상북도 경산": "11H10703",
        "경상북도 청도": "11H10704",
        "경상북도 칠곡": "11H10705",
        "울산광역시 울산": "11H20101",
        "경상남도 양산": "11H20102",
        "부산광역시 부산": "11H20201",
        "경상남도 창원": "11H20301",
        "경상남도 김해": "11H20304",
        "경상남도 통영": "11H20401",
        "경상남도 사천": "11H20402",
        "경상남도 거제": "11H20403",
        "경상남도 고성": "11H20404",
        "경상남도 남해": "11H20405",
        "경상남도 함양": "11H20501",
        "경상남도 거창": "11H20502",
        "경상남도 합천": "11H20503",
        "경상남도 밀양": "11H20601",
        "경상남도 의령": "11H20602",
        "경상남도 함안": "11H20603",
        "경상남도 창녕": "11H20604",
        "경상남도 진주": "11H20701",
        "경상남도 산청": "11H20703",
        "경상남도 하동": "11H20704"
    ]

}

//MARK: - AppGroup
extension UserDefaults {
    static var shared: UserDefaults {
        let addGroupId = "group.weatherI.widget"
        return UserDefaults(suiteName: addGroupId)!
    }
}
