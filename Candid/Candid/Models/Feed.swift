//
//  Feed.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import Foundation

class Feed: NSObject{
    var fid: Int
    var owner: User
    var imageURL: String
    var isLike: Int
    var poster: User
    var created_time: Int
    
    init(feedDictionary: [String: Any]){
        self.fid = feedDictionary["id"] as? Int ?? Int(feedDictionary["id"] as! String)!
        let ownerData = feedDictionary["owner"] as! [String: Any]
        self.owner = User(userDictionary: ownerData)
        self.imageURL = feedDictionary["imageURL"] as! String
        self.isLike = feedDictionary["isLike"] as? Int ?? Int(feedDictionary["isLike"] as! String)!
        let posterData = feedDictionary["poster"] as! [String: Any]
        self.poster = User(userDictionary: posterData)
        self.created_time = feedDictionary["created_time"] as? Int ?? Int(feedDictionary["created_time"] as! String)!
    }
    
}
