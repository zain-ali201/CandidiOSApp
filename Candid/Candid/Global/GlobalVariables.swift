//
//  GlobalVariables.swift
//  SOL
//
//  Created by khrmac on 2021/2/9.
//

import Foundation

//tQOBbRL4hhfqTqr71merG_Cq6UQsX82iEYEj4P5P
var currentUser: User?
var token: String?
var blockedUsers = [User]()

func getTimeString(timestamp: Int) -> String{
    let current = Int(Date().timeIntervalSince1970)
    let difference = current - timestamp
    if difference >= 172800{
        return "\(difference / 86400) days ago"
    }else if difference >= 86400{
        return "\(difference / 86400) day ago"
    }else if difference >= 7200{
        return "\(difference / 3600) hours ago"
    }else if difference >= 3600{
        return "\(difference / 3600) hour ago"
    }else if difference >= 120{
        return "\(difference / 60) mins ago"
    }else if difference >= 60{
        return "\(difference / 60) min ago"
    }else{
        return "\(difference) secs ago"
    }
}
