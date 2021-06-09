//
//  User.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import Foundation

class User: NSObject{
    var uid: Int
    var fullname: String
    var mobileNo: String
    var username: String
    var token: String
    var bio: String
    var isYourContact: Bool = false

    var profile_image_url: String
//    var images: [Feed]
    var isFollowing: Int?
    var badge_count: Int
    
    init(userDictionary: [String: Any]){
        self.uid = userDictionary["id"] as? Int ?? Int(userDictionary["id"] as! String)!
        self.fullname = userDictionary["fullname"] as! String
        self.mobileNo = userDictionary["mobileNo"] as! String
        self.username = userDictionary["username"] as! String
        self.token = userDictionary["token"] as! String
        if let check = userDictionary["isYourContact"] as? Bool{
            self.isYourContact = check
        }

//        let jsonData = (userDictionary["bio"] as! String).data(using: .utf8)!
//        let decoded = try! JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
        self.bio = userDictionary["bio"] as! String
        self.profile_image_url = userDictionary["profile_image_url"] as! String
//        self.images = [Feed]()
//        let imagesData = userDictionary["feeds"] as? [[String: Any]]
//        if imagesData != nil{
//            for data in imagesData!{
//                let temp = Feed(feedDictionary: data)
//                self.images.append(temp)
//            }
//        }
        self.isFollowing = userDictionary["isFollowing"] as? Int ?? Int(userDictionary["isFollowing"] as? String ?? "0")!
        self.badge_count = userDictionary["badge_count"] as? Int ?? Int(userDictionary["badge_count"] as! String)!
    }
    
}
