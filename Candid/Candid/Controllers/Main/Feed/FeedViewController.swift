//
//  FeedViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    var feeds = [Feed]()
    @IBOutlet weak var heartImageView: UIImageView!
    
    var refreshControl = UIRefreshControl()
    
    var canRefresh = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(GoTop), name: NSNotification.Name("GoTop"), object: nil)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        feedTableView.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        feedTableView.addGestureRecognizer(tapGestureRecognizer)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(userActiveToLoad), name: NSNotification.Name("active"), object: nil)
    }
    
    @objc func GoTop(){
        if feeds.count > 0{
            let indexPath = IndexPath(row: 0, section: 0)
            self.feedTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
      }
    
    @objc func userActiveToLoad(){
        if currentUser != nil{
            APIManager.shared.getFeeds(uid: currentUser!.uid) { (success, feeds, message) in
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
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        print("pull")
        self.refreshControl.endRefreshing()
        APIManager.shared.getFeeds(uid: currentUser!.uid) { (success, feeds, message) in
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
        }
    }
    
    func refresh1() {
        print("pull")
        self.refreshControl.endRefreshing()
        APIManager.shared.getFeeds(uid: currentUser!.uid) { (success, feeds, message) in
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
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APIManager.shared.getFeeds(uid: currentUser!.uid) { (success, feeds, message) in
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

extension FeedViewController: UITableViewDelegate, UITableViewDataSource{
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
        cell.layoutSubviews()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.height
        
        return height
    }
    
}

class FeedTableViewCell: UITableViewCell{
    @IBOutlet weak var mainImageView: EEZoomableImageView!{
        didSet{
            mainImageView.minZoomScale = 1.0
            mainImageView.maxZoomScale = 3.0
            mainImageView.resetAnimationDuration = 0
        }
    }
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
}

extension FeedViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50 { //change 100 to whatever you want
            if canRefresh && !self.refreshControl.isRefreshing{
                self.canRefresh = false
                self.refreshControl.beginRefreshing()
                self.refresh1()
            }
        }else if scrollView.contentOffset.y >= 0{
            self.canRefresh = true
        }
    }
}
