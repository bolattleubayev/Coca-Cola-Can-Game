//
//  Constants.swift
//  Coca Cola Can Game
//
//  Created by macbook on 5/18/20.
//  Copyright © 2020 assylkhantleubayev. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    static let color1: UIColor = #colorLiteral(red: 0.9529411765, green: 0.2078431373, blue: 0.2078431373, alpha: 1)
    static let color2: UIColor = #colorLiteral(red: 0.8470588235, green: 0.9137254902, blue: 0.9411764706, alpha: 1)
    static let color3: UIColor = #colorLiteral(red: 0.2, green: 0.2588235294, blue: 0.3568627451, alpha: 1)
    static let color4: UIColor = #colorLiteral(red: 0.1607843137, green: 0.1450980392, blue: 0.1725490196, alpha: 1)
    
    static let colaPlaces: [ColaPlace] = [
        ColaPlace(name: "NU", type: "University", latitude: 51.089719, longitude: 71.401939, phone: "232-923423", image: "cafedeadend.jpg", isVisited: false), //51.089719, 71.401939
        ColaPlace(name: "Expo", type: "Sightseeing", latitude: 51.088551, longitude: 71.416200, phone: "348-233423", image: "homei.jpg", isVisited: false), //51.088551, 71.416200
        ColaPlace(name: "Bayterek", type: "Sightseeing", latitude: 51.128044, longitude: 71.430099, phone: "354-243523", image: "teakha.jpg", isVisited: false), //51.128044, 71.430099
        ColaPlace(name: "Khan Shatyr", type: "Shopping", latitude: 51.131993, longitude: 71.405726, phone: "453-333423", image: "cafeloisl.jpg", isVisited: false), //51.131993,71.405726
        ColaPlace(name: "Keruyen", type: "Shopping", latitude: 51.127199, longitude: 71.424717, phone: "983-284334", image: "petiteoyster.jpg", isVisited: false), //51.127199, 71.424717
        ColaPlace(name: "Test Location", type: "Shopping", latitude: 51.140208, longitude: 71.385670, phone: "983-284334", image: "petiteoyster.jpg", isVisited: false)
    ]
    
    static func modifyNavigationController(navigationController: UINavigationController?) {
        // Modifying the Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = color3
        navigationController?.navigationBar.tintColor = color2
        if let customFont = UIFont(name: "Avenir", size: 25.0) {
            navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: color2, NSAttributedString.Key.font: customFont]
        }
    }
}
