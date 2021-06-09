//
//  FindPeopleViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import SwiftyContacts

class FindPeopleViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Type to search", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        }
    }
    @IBOutlet weak var usersTableView: UITableView!

    var allUsers = [User]()
    var searchedUsers = [User]()
    var searchActive = false
    var suggestedUsers = [User]()
    var otherUsers = [User]()
    var allNumbers: [String] = []
    var refreshControl = UIRefreshControl()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshContacts), for: .valueChanged)
        usersTableView.addSubview(refreshControl)
        self.swipeToPop()
        self.getAll_Contacts(loader: true)
    }
    func swipeToPop(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                // Detect swipe gesture to load next entry
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeNextEntry)))
    }
    
    @objc func swipeNextEntry(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .ended) {
            let velocity = sender.velocity(in: self.view)

            if (velocity.x > 0) { // Coming from left
                self.navigationController?.popViewController(animated: true)
            } else { // Coming from right
                print("down")
            }
        }
    }
    func searchUser(keyword: String){
        if keyword.count == 0{
            self.searchActive = false
            self.searchedUsers.removeAll()
            self.usersTableView.reloadData()
        }else{
            self.addField_Indicator()
            self.searchActive = true
            self.searchedUsers.removeAll()
            self.usersTableView.reloadData()
            APIManager.shared.searchUsers(uid: currentUser!.uid, keyword: keyword) { (success, users, message) in

                self.searchedUsers = users
                self.usersTableView.reloadData()
                self.removeField_Indicator()
            }
        }
    }
    
    func addField_Indicator(){
        let _activityHolder = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        let _activityIndicator = UIActivityIndicatorView(style: .gray)
        searchTextField.rightViewMode = UITextField.ViewMode.always
        _activityIndicator.startAnimating()
        _activityIndicator.backgroundColor = UIColor.clear
        _activityIndicator.center = CGPoint(x: _activityHolder.frame.size.width/2, y: _activityHolder.frame.size.height/2)
        _activityHolder.addSubview(_activityIndicator)
        searchTextField.rightView = _activityHolder
    }
    func removeField_Indicator(){
        searchTextField.rightView = nil
    }
    @objc func refreshContacts(){
        searchTextField.text = ""
        self.refreshControl.beginRefreshing()
        self.getUsers(loader: false)
    }

    func followUser_At(indexPath: IndexPath,selectedUser : User) {
        if selectedUser.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser.uid) { (success, message) in
                if success{
                    if self.searchActive{
                        self.searchedUsers[indexPath.row].isFollowing = 1
                    }else{
                        if indexPath.section == 0{
                            self.suggestedUsers[indexPath.row].isFollowing = 1
                        }else{
                            self.otherUsers[indexPath.row].isFollowing = 1
                        }
                    }
                    
                    
                    self.usersTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.view.layoutIfNeeded()
                    APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Follow", body: "\(currentUser!.fullname) followed you.", badge_count: selectedUser.badge_count + 1)
                    APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                        
                    }
                }
            }
        }else{
            APIManager.shared.unfollowUser(first_uid: currentUser!.uid, second_uid:selectedUser.uid) { (success, message) in
                if success{
                    
                    if success{
                        if self.searchActive{
                            self.searchedUsers[indexPath.row].isFollowing = 0
                        }else{
                            if indexPath.section == 0{
                                self.suggestedUsers[indexPath.row].isFollowing = 0
                            }else{
                                self.otherUsers[indexPath.row].isFollowing = 0
                            }
                        }
                        
                    self.usersTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
}
}
extension FindPeopleViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchActive{
            return 1
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return self.searchedUsers.count
        }else{
            if section == 0{
                return self.suggestedUsers.count
            }else{
                return self.otherUsers.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")!
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let followButton = cell.viewWithTag(3) as! UIButton
        nameLabel.font = AppFont.SemiBold.size(15)
        var selectedUser : User?
        if searchActive{
            selectedUser = self.searchedUsers[indexPath.row]
        }else{
            if indexPath.section == 0{
                selectedUser = self.suggestedUsers[indexPath.row]
            }else{
                selectedUser = self.otherUsers[indexPath.row]
            }
        }
        let str = "\(image_URL)\(selectedUser?.profile_image_url ?? "")"
//        photoImageView.download(url: str, rounded: true)
        photoImageView.load(photoUrl: str, placeHolder: "avatar")
        nameLabel.text = (selectedUser?.fullname.count == 0 ? selectedUser?.username : selectedUser?.fullname)
        followButton.setImage(selectedUser?.isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
     
        followButton.onTap {
            self.followUser_At(indexPath: indexPath, selectedUser: selectedUser!)
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        if searchActive{
            vc.selectedUser = self.searchedUsers[indexPath.row]
        }else{
            if indexPath.section == 0{
                vc.selectedUser = self.suggestedUsers[indexPath.row]
            }else{
                vc.selectedUser = self.otherUsers[indexPath.row]
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        holderView.backgroundColor = .white
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor(red: 226/255.0, green: 230/255.0, blue: 240/255.0, alpha: 1.0)
        let lbl = UILabel(frame: CGRect(x: 12, y: 5, width: view.frame.size.width - 24, height: 30))
        lbl.textColor = UIColor(named: "MainBlack")
        if section == 0{
            lbl.text = "Suggested Friends".uppercased()
        }else{
            lbl.text = "Other Users".uppercased()
        }
        lbl.font = AppFont.SemiBold.size(12)
        view.addSubview(lbl)
        view.layer.cornerRadius = 11
        holderView.addSubview(view)
        
        return holderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchActive{
            return 0
        }else{
            if section == 0{
                if suggestedUsers.count > 0{
                    return 40
                }else{
                    return 0
                }
            }else{
                if otherUsers.count > 0{
                    if suggestedUsers.count > 0{
                        return 40
                    }else{
                        return 0
                    }
                }else{
                    return 0
                }
            }
        }
     
    }
    
}

extension FindPeopleViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Begin")
        self.searchActive = true
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("Ended")
//        self.searchActive = false
//    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var updatedTextString : NSString = textField.text! as NSString
        updatedTextString = updatedTextString.replacingCharacters(in: range, with: string) as NSString
        
        print(updatedTextString)
        
        self.searchUser(keyword: updatedTextString as String)
        
        
        /*if let char = string.cString(using: .utf8){
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92){
                if textField.text?.count == 0 || textField.text?.count == 1{
                    self.searchedUsers.removeAll()
                    self.searchedUsers = self.allUsers
                    self.searchActive = false
                    self.usersTableView.reloadData()
                }else{
                    self.searchActive = true
                    let keyword = String(textField.text!.dropLast())
                    self.searchUser(keyword: keyword)
                }
            }else{
                self.searchActive = true
                let keyword = "\(textField.text ?? "")\(string)"
                self.searchUser(keyword: keyword)
            }
        }*/
        return true
    }
}
