//
//  DigItem.swift
//  DigBig
//
//  Created by macbook on 5/3/20.
//  Copyright © 2020 assylkhantleubayev. All rights reserved.
//

import Foundation

struct DigItem {
    var postID: String
    var user: String
    var className: String
    var title: String
    var type: String
    var text: String
    var date: String
    var timestamp: Int
    var imageFileURL: String
    var attachedFileURL: String
    
    init(postID: String, user: String, className: String, title: String, type: String, text: String, date: String, timestamp: Int, imageFileURL: String, attachedFileURL: String) {
        self.postID = postID
        self.user = user
        self.className = className
        self.title = title
        self.type = type
        self.text = text
        self.date = date
        self.timestamp = timestamp
        self.imageFileURL = imageFileURL
        self.attachedFileURL = attachedFileURL
    }
    
    init() {self.init(postID: "", user: "", className: "", title: "", type: "", text: "", date: "", timestamp: 0, imageFileURL: "", attachedFileURL: "")}
    
    init?(postId: String, postInfo: [String: Any]) {
        guard let imageFileURL = postInfo[DigItemInfoKey.imageFileURL] as? String, let user = postInfo[DigItemInfoKey.user] as? String, let timestamp = postInfo[DigItemInfoKey.timestamp] as? Int, let className = postInfo[DigItemInfoKey.className] as? String, let title = postInfo[DigItemInfoKey.title] as? String, let type = postInfo[DigItemInfoKey.type] as? String, let text = postInfo[DigItemInfoKey.text] as? String, let date = postInfo[DigItemInfoKey.date] as? String, let attachedFileURL = postInfo[DigItemInfoKey.attachedFileURL] as? String else {
            return nil
        }
        
        self = DigItem(postID: postId, user: user, className: className, title: title, type: type, text: text, date: date, timestamp: timestamp, imageFileURL: imageFileURL, attachedFileURL: attachedFileURL)
    }
    
    // MARK: - Firebase Keys
    
    enum DigItemInfoKey {
        static let imageFileURL = "imageFileURL"
        static let user = "user"
        static let timestamp = "timestamp"
        static let attachedFileURL = "attachedFileURL"
        static let className = "className"
        static let title = "title"
        static let type = "type"
        static let text = "text"
        static let date = "date"
    }
    
    
}
