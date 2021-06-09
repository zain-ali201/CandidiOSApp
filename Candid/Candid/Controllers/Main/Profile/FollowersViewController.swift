//
//  FollowersViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class FollowersViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    
    var followers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APIManager.shared.getFollowers(uid: currentUser!.uid) { (success, users, message) in
            if success{
                self.followers = users!
                self.usersTableView.reloadData()
            }else{
                self.followers.removeAll()
                self.usersTableView.reloadData()
            }
        }
    }
    
    @IBAction func followButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.usersTableView.indexPath(for: cell)!
        let selectedUser = self.followers[indexPath.row]
        if selectedUser.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser.uid) { (success, message) in
                if success{
                    self.followers[indexPath.row].isFollowing = 1
                    self.usersTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.view.layoutIfNeeded()
                    APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Follow", body: "\(currentUser!.fullname) followed you.", badge_count: selectedUser.badge_count + 1)
                    APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                        
                    }
                }
            }
        }else{
            APIManager.shared.unfollowUser(first_uid: currentUser!.uid, second_uid: selectedUser.uid) { (success, message) in
                if success{
                    self.followers[indexPath.row].isFollowing = 0
                    self.usersTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
    

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")!
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let followButton = cell.viewWithTag(3) as! UIButton
        let selectedUser = self.followers[indexPath.row]
        photoImageView.load(photoUrl: "\(image_URL)\(selectedUser.profile_image_url)", placeHolder: "avatar")
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedUser.profile_image_url)"), placeholderImage: UIImage(named: "avatar"))
        nameLabel.text = selectedUser.fullname
        followButton.setImage(selectedUser.isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = self.followers[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FollowersViewController: UIGestureRecognizerDelegate{
}
