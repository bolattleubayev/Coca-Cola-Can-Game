//
//  PhotoCard.swift
//  Coca Cola Can Game
//
//  Created by macbook on 5/19/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import Foundation

struct PhotoCard {
    var postID: String
    var user: String
    var shopName: String
    var barCode: Int
    var longitude: Double
    var latitude: Double
    var comments: String
    var timestamp: Int
    var imageFileURL: String
    
    init(postID: String, user: String, shopName: String, barCode: Int, longitude: Double, latitude: Double, comments: String, timestamp: Int, imageFileURL: String) {
        self.postID = postID
        self.user = user
        self.shopName = shopName
        self.barCode = barCode
        self.longitude = longitude
        self.latitude = latitude
        self.comments = comments
        self.timestamp = timestamp
        self.imageFileURL = imageFileURL
    }
    
    init() {self.init(postID: "", user: "", shopName: "", barCode: 0, longitude: 0.0, latitude: 0.0, comments: "", timestamp: 0, imageFileURL: "")}
    
    init?(postId: String, postInfo: [String: Any]) {
        guard let imageFileURL = postInfo[PhotoCardInfoKey.imageFileURL] as? String, let user = postInfo[PhotoCardInfoKey.user] as? String, let timestamp = postInfo[PhotoCardInfoKey.timestamp] as? Int, let shopName = postInfo[PhotoCardInfoKey.shopName] as? String, let barCode = postInfo[PhotoCardInfoKey.barCode] as? Int, let longitude = postInfo[PhotoCardInfoKey.longitude] as? Double, let latitude = postInfo[PhotoCardInfoKey.latitude] as? Double, let comments = postInfo[PhotoCardInfoKey.comments] as? String else {
            return nil
        }
        
        self = PhotoCard(postID: postId, user: user, shopName: shopName, barCode: barCode, longitude: longitude, latitude: latitude, comments: comments, timestamp: timestamp, imageFileURL: imageFileURL)
    }
    
    // MARK: - Firebase Keys
    
    enum PhotoCardInfoKey {
        static let imageFileURL = "imageFileURL"
        static let user = "user"
        static let timestamp = "timestamp"
        static let shopName = "shopName"
        static let barCode = "barCode"
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let comments = "comments"
    }
    
    
}
