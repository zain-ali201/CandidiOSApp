//
//  Notification.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import Foundation

class Notification: NSObject{
    var nid: Int
    var opponentUser: User
    var feed: Feed?
    var postType: Int
    var time: Int
    
    init(notificationDictionary: [String: Any]){
        self.nid = notificationDictionary["id"] as? Int ?? Int(notificationDictionary["id"] as! String)!
        let opponentData = notificationDictionary["opponent"] as! [String: Any]
        self.opponentUser = User(userDictionary: opponentData)
        let feedData = notificationDictionary["feed"] as? [String: Any]
        if feedData != nil{
            self.feed = Feed(feedDictionary: feedData!)
        }
        
        self.postType = notificationDictionary["postType"] as? Int ?? Int(notificationDictionary["postType"] as! String)!
        self.time = notificationDictionary["time"] as? Int ?? Int(notificationDictionary["created_time"] as! String)!
    }
    
}
