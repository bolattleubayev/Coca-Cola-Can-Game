//
//  File.swift
//  Copyright © 2020 assylkhantleubayev. All rights reserved.

import Foundation

class ColaPlace: Equatable {
    
    static func == (lhs: ColaPlace, rhs: ColaPlace) -> Bool {
        if lhs.name == rhs.name, lhs.latitude == rhs.latitude, lhs.longitude == rhs.longitude {
            return true
        } else {
            return false
        }
    }
    
    var name = ""
    var type = ""
    var latitude = 0.0
    var longitude = 0.0
    var image = ""
    var isVisited = false
    var phone = ""
    var rating = ""
    
    init(name: String, type: String, latitude: Double, longitude: Double, phone: String, image: String, isVisited: Bool) {
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.image = image
        self.isVisited = isVisited
    }
}
