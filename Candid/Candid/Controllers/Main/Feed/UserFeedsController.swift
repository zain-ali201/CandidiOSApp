//
//  UserFeedsController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit

class UserFeedsController: UIViewController ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var feedTableView: UITableView!
    var feeds = [Feed]()
    @IBOutlet weak var heartImageView: UIImageView!
    var isMyProfile = false
//    var refreshControl = UIRefreshControl()
    @IBOutlet weak var backBTN: UIButton!
    @IBOutlet weak var blockBTN: UIButton!

    @IBOutlet weak var headerLBL: UILabel!
    var selectedUser : User?
    var selectedIndex = IndexPath(row: 0, section: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.alpha = 0
        swipeToPop()
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        feedTableView.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        feedTableView.addGestureRecognizer(tapGestureRecognizer)
        
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
//        feedTableView.addSubview(refreshControl)

        //backBTN.imageEdgeInsets = UIEdgeInsets(top: 17,left: 12,bottom: 17,right: 12)

        headerLBL.font = AppFont.Regular.size(17)
        if isMyProfile{
            self.blockBTN.isUserInteractionEnabled = false
            self.blockBTN.alpha = 0
            let text = "My Feeds"
            let attribText = text.withBoldText(text: "My Feeds")
            headerLBL.attributedText =  attribText
        }else{
            let text = "\(selectedUser?.fullname ?? "") Feeds"
            let attribText = text.withBoldText(text: "\(selectedUser?.fullname ?? "")")
            headerLBL.attributedText =  attribText
        }
        backBTN.onTap {
            self.navigationController?.popViewController(animated: true)
        }
        feedTableView.reloadData {
            self.feedTableView.alpha = 1

            self.feedTableView.scrollToRow(at: self.selectedIndex, at: .middle, animated: false)
        }
        blockBTN.onTap {
            self.blockME()
        }
    }
    

    func blockME(){
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
    @objc func refresh(_ sender: AnyObject) {
       /* self.refreshControl.beginRefreshing()
        APIManager.shared.getFeeds(uid: selectedUser!.uid) { (success, feeds, message) in
            self.refreshControl.endRefreshing()
            if success{
                self.feeds = feeds!
                for feed in self.feeds{
                    for blockedUser in blockedUsers{
                        if feed.owner.uid == blockedUser.uid || feed.poster.uid == blockedUser.uid{
                            self.feeds = self.feeds.filter {$0 != feed}
                        }
                    }
                }
                self.feedTableView.reloadData()
            }else{
                self.feeds.removeAll()
                self.feedTableView.reloadData()
            }
        }*/
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: feedTableView)
        if let indexPath = feedTableView.indexPathForRow(at: touchPoint) {
            print(indexPath)
        }
    }

    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: feedTableView)
        if let indexPath = feedTableView.indexPathForRow(at: touchPoint) {
            let selectedFeed = self.feeds[indexPath.row]
            let location = self.feedTableView.rectForRow(at: indexPath)
            let cellRect = location.offsetBy(dx: -self.feedTableView.contentOffset.x, dy: -self.feedTableView.contentOffset.y)
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
                        self.feeds[indexPath.row].isLike = 1
                        self.feedTableView.reloadRows(at: [indexPath], with: .none)
                        APIManager.shared.sendPushNotification(to: selectedFeed.owner.token, title: "Like", body: "\(currentUser!.fullname) liked your photo", badge_count: selectedFeed.owner.badge_count + 1)
                        APIManager.shared.updateBadgeCount(uid: selectedFeed.owner.uid, badge_count: selectedFeed.owner.badge_count + 1) { (success, message) in
                            
                        }
                    }
                }
            }else{
                APIManager.shared.unlikeFeed(fid: selectedFeed.fid, uid: currentUser!.uid, owner_uid: selectedFeed.owner.uid) { (success, message) in
                    if success{
                        self.feeds[indexPath.row].isLike = 0
                        self.feedTableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
  
    
    @IBAction func usernameButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.feedTableView.indexPath(for: cell)!
        let selectedUser = self.feeds[indexPath.row].owner
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = selectedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func posterButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.feedTableView.indexPath(for: cell)!
        let selectedUser = self.feeds[indexPath.row].poster
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = selectedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reportButtonClicked(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.feedTableView.indexPath(for: cell)!
        let selectedUser = self.feeds[indexPath.row].owner
        
        if isMyProfile{
            let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction(title: "Delete Image", style: .default) { (action) in
                APIManager.shared.deleteImage(fid: self.feeds[indexPath.row].fid) { (success, message) in
                    if success{
                        self.feeds.remove(at: indexPath.row)
                        self.feedTableView.reloadData()
                        
                        if self.feeds.count == 0{
                            self.navigationController?.popViewController(animated: true)
                        }
//                        self.feedTableView.beginUpdates()
//                        self.feedTableView.deleteRows(at: [indexPath], with: .fade)
//                        self.feedTableView.endUpdates()
                    }else{
                        self.view.makeToast(message)
                    }
                }
                
            }
          
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(reportAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        }else{
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
                for feed in self.feeds{
                    for blockedUser in blockedUsers{
                        if feed.owner.uid == blockedUser.uid || feed.poster.uid == blockedUser.uid{
                            self.feeds = self.feeds.filter {$0 != feed}
                        }
                    }
                }
                self.feedTableView.reloadData()
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
    
}

extension UserFeedsController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as! FeedTableViewCell
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let usernameButton = cell.viewWithTag(2) as! UIButton
        let posterButton = cell.viewWithTag(4) as! UIButton
        let likeView = cell.viewWithTag(5)!
        if isMyProfile{
            posterButton.isUserInteractionEnabled = false
            posterButton.alpha = 0
        }else{
            posterButton.isUserInteractionEnabled = true
            posterButton.alpha = 1
        }
//        let width = UIImage(named: "template")!.size.width
//        let height = UIImage(named: "template")!.size.height
//        cell.heightConstraint.constant = self.view.frame.width * height / width
        let selectedFeed = self.feeds[indexPath.row]
//        cell.mainImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"), placeholderImage: UIImage(named: "template"))
        cell.mainImageView.load(photoUrl: "\(image_URL)\(selectedFeed.imageURL)", placeHolder: "")
//        cell.mainImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"))
        profileImageView.load(photoUrl: "\(image_URL)\(selectedFeed.owner.profile_image_url)", placeHolder: "avatar")
//        profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.owner.profile_image_url)"), placeholderImage: UIImage(named: "avatar"))
        usernameButton.setTitle(selectedFeed.owner.fullname, for: .normal)
        posterButton.setTitle("By \(selectedFeed.poster.fullname)", for: .normal)
        
        let gradient = CAGradientLayer()
        gradient.frame = likeView.bounds
//        gradient.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = [UIColor(red: 247 / 255, green: 58 / 255, blue: 196 / 255, alpha: 1.0).cgColor, UIColor(red: 55 / 255, green: 158 / 255, blue: 246 / 255, alpha: 1.0).cgColor, UIColor(red: 245 / 255, green: 249 / 255, blue: 70 / 255, alpha: 1.0).cgColor, UIColor(red: 243 / 255, green: 78 / 255, blue: 78 / 255, alpha: 1.0).cgColor]
        likeView.layer.insertSublayer(gradient, at: 0)
        likeView.isHidden = selectedFeed.isLike == 0 ? true : false
        cell.heightConstraint.constant = tableView.frame.height - 110
        return cell
    }
    
}


extension UITableView {
func reloadData(completion:@escaping ()->()) {
    UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
}
}
