//
//  OtherProfileController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit
import Closures

class OtherProfileController: UIViewController {
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var heartImageView: UIImageView!{
        didSet{
            heartImageView.alpha = 0
        }
    }
    var userFeeds = [Feed]()
    var selectedUser: User?
    @IBOutlet var profileTable : UITableView!{
        didSet{
            profileTable.dataSource = self
            profileTable.delegate = self
            profileTable.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.imageEdgeInsets = UIEdgeInsets(top: 10,left: 5,bottom: 10,right: 5)
        backButton.onTap {
            self.navigationController?.popViewController(animated: true)
        }
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        profileTable.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        profileTable.addGestureRecognizer(tapGestureRecognizer)
        
        setUser_Data()
        getuser_feeds()
        swipeToPop()
        moreButton.onTap {
            self.blockAction()
        }
    }
    
    func blockAction() {
        let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
        
        let blockAction = UIAlertAction(title: "Block User", style: .default) { (action) in
            blockedUsers.append(self.selectedUser!)
            if var topController = UIApplication.shared.windows.first!.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.view.makeToast("Thank you for your action. This user is blocked.")
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func followAction(){
        if selectedUser!.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser!.uid) { (success, message) in
                if success{
                    self.selectedUser?.isFollowing = 1
                    self.followButton.setBackgroundImage(UIImage(named: "followed_button"), for: .normal)
                    self.view.layoutIfNeeded()
                    APIManager.shared.sendPushNotification(to: self.selectedUser!.token, title: "Follow", body: "\(currentUser!.fullname) followed you.", badge_count: self.selectedUser!.badge_count + 1)
                    APIManager.shared.updateBadgeCount(uid: self.selectedUser!.uid, badge_count: self.selectedUser!.badge_count + 1) { (success, message) in
                        
                    }
                }
            }
        }else{
            APIManager.shared.unfollowUser(first_uid: currentUser!.uid, second_uid: selectedUser!.uid) { (success, message) in
                if success{
                    self.selectedUser?.isFollowing = 0
                    self.followButton.setBackgroundImage(UIImage(named: "follow_button"), for: .normal)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func setUser_Data(){
        self.fullnameLabel.text = selectedUser?.fullname
        self.usernameLabel.text = selectedUser?.username
        self.bioLabel.text = selectedUser?.bio
        let imgURL = "\(image_URL)\(selectedUser?.profile_image_url ?? "")"
        self.profileImageView.load(photoUrl: imgURL, placeHolder: "avatar")
//        self.profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedUser?.profile_image_url ?? "")"), placeholderImage: UIImage(named: "avatar"))
        self.followButton.setBackgroundImage(selectedUser?.isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
        
        self.followButton.onTap {
            self.followAction()
        }
        self.uploadButton.onTap {
            self.uploadAction()
        }
    }
    
    func uploadAction(){
        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "CamController") as? CamController
        vc?.hidesBottomBarWhenPushed = true
        vc?.uploadingUser = self.selectedUser
        vc?.isPushing = true
        self.navigationController?.fadeTo(vc!)
    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: profileTable)
        if let indexPath = profileTable.indexPathForRow(at: touchPoint) {
            print(indexPath)
        }
    }

    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: profileTable)
        if let indexPath = profileTable.indexPathForRow(at: touchPoint) {
            let selectedFeed = self.userFeeds[indexPath.row]
            let location = self.profileTable.rectForRow(at: indexPath)
            let cellRect = location.offsetBy(dx: -self.profileTable.contentOffset.x, dy: -self.profileTable.contentOffset.y)
            self.heartImageView.frame = CGRect(origin: CGPoint(x: (cellRect.size.width / 2) - 20 , y: (cellRect.size.height / 2) + cellRect.origin.y + 24), size: CGSize(width: 70, height: 70))
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                self.heartImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.heartImageView.alpha = 1.0
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.heartImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: {(_ finished: Bool) -> Void in
                    UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                        self.heartImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                        self.heartImageView.alpha = 0.0
                    }, completion: {(_ finished: Bool) -> Void in
                        self.heartImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
                })
            })
            
            if selectedFeed.isLike == 0{
                APIManager.shared.likeFeed(fid: selectedFeed.fid, uid: currentUser!.uid, owner_uid: selectedFeed.owner.uid) { (success, message) in
                    if success{
                        self.userFeeds[indexPath.row].isLike = 1
                        self.profileTable.reloadRows(at: [indexPath], with: .none)
                        APIManager.shared.sendPushNotification(to: selectedFeed.owner.token, title: "Like", body: "\(currentUser!.fullname) liked your photo", badge_count: selectedFeed.owner.badge_count + 1)
                        APIManager.shared.updateBadgeCount(uid: selectedFeed.owner.uid, badge_count: selectedFeed.owner.badge_count + 1) { (success, message) in
                            
                        }
                    }
                }
            }else{
                APIManager.shared.unlikeFeed(fid: selectedFeed.fid, uid: currentUser!.uid, owner_uid: selectedFeed.owner.uid) { (success, message) in
                    if success{
                        self.userFeeds[indexPath.row].isLike = 0
                        self.profileTable.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
    
    func getuser_feeds(){
        APIManager.shared.getMyImages(uid: selectedUser!.uid) { (success, feeds, message) in
            self.userFeeds = feeds ?? []
            self.profileTable.reloadData()
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OtherProfileController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userFeeds.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as! FeedTableViewCell
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let usernameButton = cell.viewWithTag(2) as! UIButton
        let posterButton = cell.viewWithTag(4) as! UIButton
        let moreBTN = cell.viewWithTag(99) as! UIButton

        let likeView = cell.viewWithTag(5)!
        let selectedFeed = self.userFeeds[indexPath.row]
        cell.mainImageView.load(photoUrl: "\(image_URL)\(selectedFeed.imageURL)", placeHolder: "")
//        cell.mainImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"))
        profileImageView.load(photoUrl: "\(image_URL)\(selectedFeed.owner.profile_image_url)", placeHolder: "avatar")
//        profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.owner.profile_image_url)"), placeholderImage: UIImage(named: "avatar"))
        usernameButton.setTitle(selectedFeed.owner.fullname, for: .normal)
        posterButton.setTitle("By \(selectedFeed.poster.fullname)", for: .normal)
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 12, y: 0, width: likeView.frame.size.width - 24, height: 5)
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = [UIColor(red: 247 / 255, green: 58 / 255, blue: 196 / 255, alpha: 1.0).cgColor, UIColor(red: 55 / 255, green: 158 / 255, blue: 246 / 255, alpha: 1.0).cgColor, UIColor(red: 245 / 255, green: 249 / 255, blue: 70 / 255, alpha: 1.0).cgColor, UIColor(red: 243 / 255, green: 78 / 255, blue: 78 / 255, alpha: 1.0).cgColor]
        likeView.layer.insertSublayer(gradient, at: 0)
        likeView.isHidden = selectedFeed.isLike == 0 ? true : false
        cell.heightConstraint.constant = tableView.frame.height - 110
        
        posterButton.onTap {
            self.posterButtonClicked(index: indexPath.row)
        }
        
        moreBTN.onTap {
            self.moreAction(index: indexPath.row)
        }
        
        moreBTN.alpha = 0
        moreBTN.isUserInteractionEnabled = false
        
        return cell
    }
    
    func posterButtonClicked(index : Int) {
        let selectedUser = self.userFeeds[index].poster
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileController") as! OtherProfileController
        vc.selectedUser = selectedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func moreAction(index : Int){
        let selectedUser = self.userFeeds[index].owner
        let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            if var topController = UIApplication.shared.windows.first!.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.view.makeToast("Thank you for your action. Your action will be reviewed by our team soon.")
            }
        }
        
        let blockAction = UIAlertAction(title: "Block User", style: .default) { (action) in
            blockedUsers.append(selectedUser)
            for feed in self.userFeeds{
                for blockedUser in blockedUsers{
                    if feed.owner.uid == blockedUser.uid || feed.poster.uid == blockedUser.uid{
                        self.userFeeds = self.userFeeds.filter {$0 != feed}
                    }
                }
            }
            self.profileTable.reloadData()
            if var topController = UIApplication.shared.windows.first!.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.view.makeToast("Thank you for your action. This user is blocked.")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(reportAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
}
extension OtherProfileController : UITableViewDelegate,OtherProfileHeaderDelegate{
    func followTapped() {
        let cell = self.profileTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! OtherProfileHeaderCell

        if selectedUser!.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser!.uid) { (success, message) in
                if success{
                    self.selectedUser?.isFollowing = 1
                    cell.followButton.setBackgroundImage(UIImage(named: "followed_button"), for: .normal)
                    self.view.layoutIfNeeded()
                    APIManager.shared.sendPushNotification(to: self.selectedUser!.token, title: "Follow", body: "\(currentUser!.fullname) followed you.", badge_count: self.selectedUser!.badge_count + 1)
                    APIManager.shared.updateBadgeCount(uid: self.selectedUser!.uid, badge_count: self.selectedUser!.badge_count + 1) { (success, message) in
                        
                    }
                }
            }
        }else{
            APIManager.shared.unfollowUser(first_uid: currentUser!.uid, second_uid: selectedUser!.uid) { (success, message) in
                if success{
                    self.selectedUser?.isFollowing = 0
                    cell.followButton.setBackgroundImage(UIImage(named: "follow_button"), for: .normal)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    func posterTapped_With(index: Int) {
        
    }
    
    func moreTapped_With(index: Int) {
        let selectedUser = self.userFeeds[index].owner
        
        let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            self.reportAction()
        }
        
        let blockAction = UIAlertAction(title: "Block User", style: .default) { (action) in
            blockedUsers.append(selectedUser)
            for feed in self.userFeeds{
                for blockedUser in blockedUsers{
                    if feed.owner.uid == blockedUser.uid || feed.poster.uid == blockedUser.uid{
                        self.userFeeds = self.userFeeds.filter {$0 != feed}
                    }
                }
            }
            self.profileTable.reloadData()
            self.showToast(message: "Thank you for your action. This user is blocked.")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(reportAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    func reportAction(){
        self.showToast(message: "Thank you for your action. Your action will be reviewed by our team soon.")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
extension OtherProfileController: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
                return false
            }
        return true
    }
}



extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
}
