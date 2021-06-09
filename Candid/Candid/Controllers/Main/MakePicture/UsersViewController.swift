//
//  UsersViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import EzPopup

class UsersViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    
    var takenPhoto: UIImage?
    
    var users = [User]()
    var foundUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.attributedPlaceholder = NSAttributedString(string: "Type to search", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        // Do any additional setup after loading the view.
        APIManager.shared.getUsers(uid: currentUser!.uid, loader: true) { (success, users, message) in
            if success{
                self.users = users
                self.foundUsers = self.users
                self.usersTableView.reloadData()
            }
        }
        self.swipeToPop()
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
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.usersTableView.indexPath(for: cell)!
        let selectedUser = self.foundUsers[indexPath.row]
        let imageName = "\(currentUser!.uid)\(Int(Date().timeIntervalSince1970)).jpg"
        APIManager.shared.uploadImage(image: self.takenPhoto!, imageName: imageName) { (success) in
            if success{
                APIManager.shared.submitRequest(owner_uid: selectedUser.uid, imageURL: imageName, poster_uid: currentUser!.uid, isApproved: 0) { (success, fid, message) in
                    if success{
                        APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Share", body: "\(currentUser!.fullname) sent a photo to your queue", badge_count: selectedUser.badge_count + 1)
                        APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                            
                        }
                        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "SentDoneViewController") as! SentDoneViewController
                        contentVC.delegate = self
                        contentVC.fullname = selectedUser.fullname
                        contentVC.takenPhoto = self.takenPhoto
                        let width = self.view.frame.width - 60
                        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
                        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
                        popupVC.backgroundAlpha = 0.65
                        popupVC.canTapOutsideToDismiss = true
                        self.present(popupVC, animated: false, completion: nil)
                    }else{
                        self.view.makeToast(message)
                    }
                }
            }else{
                self.view.makeToast("Something went wrong. Try again later.")
            }
        }
        
    }
    
    func searchUser(keyword: String){
        self.foundUsers.removeAll()
        APIManager.shared.searchUsers(uid: currentUser!.uid, keyword: keyword) { (success, users, message) in
            if success{
                self.foundUsers = users
                self.usersTableView.reloadData()
            }else{
                self.usersTableView.reloadData()
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foundUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")!
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let selectedUser = self.foundUsers[indexPath.row]
        photoImageView.load(photoUrl: "\(image_URL)\(selectedUser.profile_image_url)", placeHolder: "avatar")
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedUser.profile_image_url)"), placeholderImage: UIImage(named: "avatar"))
        nameLabel.text = selectedUser.fullname
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = self.foundUsers[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UsersViewController: SentDoneViewControllerDelegate{
    func done() {
        
    }
}

extension UsersViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        if let char = string.cString(using: .utf8){
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92){
                if textField.text?.count == 0 || textField.text?.count == 1{
                    self.foundUsers.removeAll()
                    self.foundUsers = self.users
                    self.usersTableView.reloadData()
                }else{
                    let keyword = String(textField.text!.dropLast())
                    self.searchUser(keyword: keyword)
                }
            }else{
                let keyword = "\(textField.text ?? "")\(string)"
                self.searchUser(keyword: keyword)
            }
        }
        return true
    }
}

extension UsersViewController: UIGestureRecognizerDelegate{
    
}
