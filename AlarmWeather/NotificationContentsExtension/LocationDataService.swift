//
//  LocationData.swift
//  AlarmWeather
//
//  Created by Deokhun KIM on 2023/06/09.
//

import Foundation

class LocationDataService {
    
    //MARK: - Properties
    
    static let shared = LocationDataService()
    
    static var x = 0
    static var y = 0
    static var administrativeArea = ""
    
    private init() { }
}
