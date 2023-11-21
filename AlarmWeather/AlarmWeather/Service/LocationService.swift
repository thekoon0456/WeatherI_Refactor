//
//  LocationService.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/29.
//

import CoreLocation
import Foundation

final class LocationService {
    
    //MARK: - Properties
    
    static let shared = LocationService()
    var manager = CLLocationManager()
    var location: CLLocation?
    
    lazy var longitude: Double? = location?.coordinate.longitude
    lazy var latitude: Double? = location?.coordinate.latitude
    
    //noti로 보낼 x,y 값
    var convertedX = 0
    var convertedY = 0
    
    let locale = Locale(identifier: "Ko-kr")
    var userRegion: String? //메인화면에 나오는 현재 유저 위치 주소
    var administrativeArea: String? //강원도 //noti로 보낼 dust 값
    var localityRegion: String? //춘천시
    var subLocalityRegion: String? //동면
    
    private init() { }
    
    func getLocation(location: CLLocation, completion: @escaping (CLLocation) -> Void) {
        // 위치 가져오기
        //        manager.requestWhenInUseAuthorization()
        //거리 정확도
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters //위치 정확도: 100미터
        //        manager.distanceFilter = 3000 // 3키로 이동할때마다 업데이트
        //        manager.allowsBackgroundLocationUpdates = true // 백그라운드 위치 업데이트 허용
        completion(location)
    }
    
    func locationToString(location: CLLocation, completion: @escaping () -> (Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: self.locale) { [weak self] placemarks, _ in
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
            } else {
                //주소가 도로명 주소일때
                if let administrative = placemarks.first?.administrativeArea,
                   let name = placemarks.first?.name {
                    userRegion = administrative + " " + name
                    administrativeArea = administrative
                    print("DEBUG: 현재 주소는 도로명: \(String(describing: userRegion))입니다.")
                }
            }
            
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
}



//MARK: - 위도, 경도를 기상청 X,Y 좌표로 변환

extension LocationService {
    func convertGRID_GPS(mode: Int = 0, lat_X: Double, lng_Y: Double) -> LatXLngY {
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO:Double = 43 // 기준점 X좌표(GRID)
        let YO:Double = 136 // 기1준점 Y좌표(GRID)
        
        // LCC DFS 좌표변환 ( code : "TO_GRID"(위경도->좌표, lat_X:위도,  lng_Y:경도), "TO_GPS"(좌표->위경도,  lat_X:x, lng_Y:y) )
        
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        var rs = LatXLngY(lat: 0, lng: 0, x: 0, y: 0)
        
        if mode == 0 {
            rs.lat = lat_X
            rs.lng = lng_Y
            var ra = tan(Double.pi * 0.25 + (lat_X) * DEGRAD * 0.5)
            ra = re * sf / pow(ra, sn)
            var theta = lng_Y * DEGRAD - olon
            if theta > Double.pi {
                theta -= 2.0 * Double.pi
            }
            if theta < -Double.pi {
                theta += 2.0 * Double.pi
            }
            
            theta *= sn
            rs.x = Int(floor(ra * sin(theta) + XO + 0.5))
            rs.y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        }
        else {
            rs.x = Int(lat_X)
            rs.y = Int(lng_Y)
            let xn = lat_X - XO
            let yn = ro - lng_Y + YO
            var ra = sqrt(xn * xn + yn * yn)
            if (sn < 0.0) {
                ra = -ra
            }
            var alat = pow((re * sf / ra), (1.0 / sn))
            alat = 2.0 * atan(alat) - Double.pi * 0.5
            
            var theta = 0.0
            if (abs(xn) <= 0.0) {
                theta = 0.0
            }
            else {
                if (abs(yn) <= 0.0) {
                    theta = Double.pi * 0.5
                    if (xn < 0.0) {
                        theta = -theta
                    }
                }
                else {
                    theta = atan2(xn, yn)
                }
            }
            let alon = theta / sn + olon
            rs.lat = alat * RADDEG
            rs.lng = alon * RADDEG
        }
        
        return rs
    }
    
    struct LatXLngY {
        public var lat: Double
        public var lng: Double
        
        public var x: Int
        public var y: Int
    }
}

////MARK: - 커스텀 주소 확인 가능
//func customLocation() {
//        let geocoder = CLGeocoder()
//        let locale = Locale(identifier: "Ko-kr")
//        let address = "대한민국 강원도 춘천시 효자동 17-1"
//
//        geocoder.geocodeAddressString(address, in: nil, preferredLocale: locale) { placemarks, error in
//            if let error = error {
//                print("Geocoding failed with error: \(error.localizedDescription)")
//                return
//            }
//
//            if let placemark = placemarks?.first {
//
//                let locality = placemark.locality ?? ""
//                let sublocality = placemark.subLocality ?? ""
//                let administrativeArea = placemark.administrativeArea ?? ""
//
//                self.userRegion = locality + " " + sublocality
//                self.localityRegion = locality
//                self.subLocalityRegion = sublocality
//                self.administrativeArea = administrativeArea
//
//                print("Locality: \(locality)")
//                print("Sublocality: \(sublocality)")
//                print("Administrative Area: \(administrativeArea)")
//            }
//        }
//}

