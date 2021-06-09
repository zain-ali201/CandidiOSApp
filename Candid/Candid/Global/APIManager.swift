
//  APIManager.swift
//  Shannon
//
//  Created by Shannon on 2021/2/10.
//  Copyright © 2021 SOL. All rights reserved.


import Foundation
import Alamofire
import SVProgressHUD

let SERVER_URL = "http://3.15.59.198/mobileAPI/api.php"
//let image_URL = "http://3.15.59.198/mobileAPI/userImages/"
let image_URL = "https://candid-us-east-2-images.s3.us-east-2.amazonaws.com/userImages/"
class APIManager {

    class var shared: APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }
        return Static.instance
    }

    //Earlier ---- "registerUser"
    func registerUser(fullname: String, username: String, password: String, phoneNumber: String, token: String, bio : String,profile_image_url: String, completion: @escaping(_ sucess: Bool, _ uid: Int?, _ error: String?) -> Void){
        let parameters: Parameters = [
            "action": "registerUserField",
            "fullname": fullname,
            "username": username,
            "password": password,
            "mobileNo": phoneNumber,
            "token": token,
            "bio": bio,
            "profile_image_url": profile_image_url,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()

        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            print(response)
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let userID = resultDict["data"] as! Int
                    completion(true, userID, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }

    func login(username: String, password: String, token: String, completion: @escaping(_ sucess: Bool, _ userData: User?, _ error: String?) -> Void){

        let parameters: Parameters = [
            "action": "login",
            "username": username,
            "password": password,
            "token": token,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let userDict = resultDict["data"] as! [String: Any]
                    completion(true, User(userDictionary: userDict), nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func updateToken(id: Int, token: String, completion: @escaping(_ sucess: Bool, _ error: String?) -> Void){
        let parameters: Parameters = [
            "action": "updateToken",
            "id": id,
            "token": token,
        ]

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()

        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, resultDict["message"] as? String)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func confirmVerificationCode(id: Int, verificationCode: String, completion: @escaping(_ sucess: Bool, _ user: User?, _ error: String?) -> Void){
        let parameters: Parameters = [
            "action": "confirmCode",
            "id": id,
            "verification_code": verificationCode,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()

        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let data = resultDict["data"] as! [String: Any]
                    let user = User(userDictionary: data)
                    completion(true, user, resultDict["message"] as? String)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func updateProfile(id: Int, fullname: String, username: String, bio: String, profile_image_url: String,loader:Bool, completion: @escaping(_ sucess: Bool, _ error: String?) -> Void){
        let parameters: Parameters = [
            "action": "updateProfile",
            "id": id,
            "fullname": fullname,
            "username": username,
            "bio": bio,
            "profile_image_url": profile_image_url,
        ]

        if loader{
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }
     

        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            if loader{
                SVProgressHUD.dismiss()
            }
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getMyImages(uid: Int, completion: @escaping(_ sucess: Bool, _ feeds: [Feed]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getMyImages",
            "uid": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let feedsDictArray = resultDict["data"] as! [[String: Any]]
                    var feeds = [Feed]()
                    for i in 0 ..< feedsDictArray.count{
                        let temp = Feed(feedDictionary: feedsDictArray[i])
                        feeds.append(temp)
                    }
                    
                    feeds.sort(by: {$0.created_time > $1.created_time})
                    completion(true, feeds, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func deleteImage(fid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "deleteImage",
            "fid": fid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getMyPendingImages(uid: Int, completion: @escaping(_ sucess: Bool, _ feeds: [Feed]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getMyPendingImages",
            "uid": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let feedsDictArray = resultDict["data"] as! [[String: Any]]
                    var feeds = [Feed]()
                    for i in 0 ..< feedsDictArray.count{
                        let temp = Feed(feedDictionary: feedsDictArray[i])
                        feeds.append(temp)
                    }
                    feeds.sort(by: {$0.fid > $1.fid})
                    completion(true, feeds, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func approveRequest(fid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "approveRequest",
            "fid": fid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getServer_Users(uid: Int,loader : Bool, completion: @escaping(_ sucess: Bool, _ users: [User], _ message: String?) -> Void){
        let parameters: Parameters = [
            "action": "getAllExistingList",
            "id": uid,
            "mobile":[],
        ]
        if loader{
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            if loader{
                SVProgressHUD.dismiss()
            }
            switch response.result{
            case .failure(_):
                completion(false, [], "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, [], resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getUsers(uid: Int,loader : Bool, completion: @escaping(_ sucess: Bool, _ users: [User], _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getUsers",
            "id": uid,
        ]

        if loader{
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }
        
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            if loader{
                SVProgressHUD.dismiss()
            }
            switch response.result{
            case .failure(_):
                completion(false, [], "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, [], resultDict["message"] as? String)
                }
            }
        }
    }
    
    func searchUsers(uid: Int, keyword: String, completion: @escaping(_ sucess: Bool, _ users: [User], _ message: String?) -> Void){

        self.stopAllSessions()
        let parameters: Parameters = [
            "action": "searchUsers",
            "id": uid,
            "keyword": keyword,
        ]
        print(parameters)

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, [], "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                print(success)
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, [], resultDict["message"] as? String)
                }
            }
        }
    }
    func stopAllSessions() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }

    func getFeeds(uid: Int, completion: @escaping(_ sucess: Bool, _ feeds: [Feed]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getFeeds",
            "id": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let feedsDictArray = resultDict["data"] as! [[String: Any]]
                    var feeds = [Feed]()
                    for i in 0 ..< feedsDictArray.count{
                        let temp = Feed(feedDictionary: feedsDictArray[i])
                        feeds.append(temp)
                    }
                    
                    feeds.sort(by: {$0.created_time > $1.created_time})
                    completion(true, feeds, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getMyNotifications(uid: Int, completion: @escaping(_ sucess: Bool, _ feeds: [Notification]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getMyNotifications",
            "id": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    if let notificationsDictArray = resultDict["data"] as? [[String: Any]]{
                        var notifications = [Notification]()
                        for i in 0 ..< notificationsDictArray.count{
                            let temp = Notification(notificationDictionary: notificationsDictArray[i])
                            notifications.append(temp)
                        }
                        
                        notifications.sort(by: {$0.time > $1.time})
                        completion(true, notifications, nil)
                    }else{
                        completion(true, [Notification](), "No notification")
                    }
                    
                    
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getFollowings(uid: Int, completion: @escaping(_ sucess: Bool, _ users: [User]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getFollowings",
            "uid": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getFollowers(uid: Int, completion: @escaping(_ sucess: Bool, _ users: [User]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getFollowers",
            "uid": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func submitRequest(owner_uid: Int, imageURL: String, poster_uid: Int, isApproved: Int, completion: @escaping(_ sucess: Bool, _ fid: Int?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "submitRequest",
            "owner_uid": owner_uid,
            "imageURL": imageURL,
            "poster_uid": poster_uid,
            "isApproved": isApproved,
        ]

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let fid = (resultDict["data"] as? Int) ?? (Int(resultDict["data"] as! String))
                    completion(true, fid, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func sendPushNotification(to token: String, title: String, body: String, badge_count: Int){
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "sound": "default",
                "badge": badge_count,
            ],
            "priority": "high"
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA-Qqo6dw:APA91bEKun-vLLrn_RLIMjPl1W9ocSQiToqPUJso5C6un0vyo_hrbt53W0JU2SHJiVPstc6ubAbw4i9q8n8aoSYhTh8GBx6Djl3g97sxFpM5c17VIlsulSWfZGeXQFz4fdO6cW1HX00c", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do{
                if let jsonData = data{
                    if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]{
                        print("received \(jsonDataDict)")
                    }
                }
            }catch let err as NSError{
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func updateBadgeCount(uid: Int, badge_count: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "updateBadgeCount",
            "uid": uid,
            "badge_count": badge_count,
        ]

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func getFriends(uid: Int, completion: @escaping(_ sucess: Bool, _ users: [User]?, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "getFriends",
            "uid": uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, nil, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    let usersDictArray = resultDict["data"] as! [[String: Any]]
                    var users = [User]()
                    for i in 0 ..< usersDictArray.count{
                        let temp = User(userDictionary: usersDictArray[i])
                        users.append(temp)
                    }
                    completion(true, users, nil)
                }else{
                    completion(false, nil, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func followUser(first_uid: Int, second_uid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "followUser",
            "first_uid": first_uid,
            "second_uid": second_uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func unfollowUser(first_uid: Int, second_uid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "unfollowUser",
            "first_uid": first_uid,
            "second_uid": second_uid,
        ]

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func likeFeed(fid: Int, uid: Int, owner_uid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "likeFeed",
            "fid": fid,
            "uid": uid,
            "owner_uid": owner_uid,
        ]

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }
    
    func unlikeFeed(fid: Int, uid: Int, owner_uid: Int, completion: @escaping(_ sucess: Bool, _ message: String?) -> Void){

        let parameters: Parameters = [
            "action": "unlikeFeed",
            "fid": fid,
            "uid": uid,
            "owner_uid": owner_uid,
        ]

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.request(SERVER_URL, method: .get, parameters: parameters).responseJSON { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false, "Network issues, try again later!")
            case .success(let result):
                let resultDict = result as! [String: Any]
                let success = (resultDict["success"] as? Int) ?? (Int(resultDict["success"] as! String))
                if success == 1{
                    completion(true, nil)
                }else{
                    completion(false, resultDict["message"] as? String)
                }
            }
        }
    }

    func uploadImage(image: UIImage, imageName: String, completion: @escaping(_ sucess: Bool) -> Void){
        let imgData = image.jpegData(compressionQuality: 0.5)
        let parameters : Parameters = ["action": "uploadImage"] as [String : Any]

        print("++++++++++++++++++++++++++++++++")
        print(parameters)
        print(imageName)
        print("++++++++++++++++++++++++++++++++")

//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData!, withName: "userImage", fileName: imageName, mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: SERVER_URL).response { (response) in
//            SVProgressHUD.dismiss()
            switch response.result{
            case .failure(_):
                completion(false)
                print(response)
                
            case .success(_):
                if response.debugDescription.contains("\"success\":\"1\""){
                    completion(true)
                }else{
                    completion(false)
                }
               
                
            }
        }

    }
}

