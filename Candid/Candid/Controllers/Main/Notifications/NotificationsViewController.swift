//
//  NotificationsViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import EzPopup

class NotificationsViewController: UIViewController {
    
    let brinjalColor = UIColor(hex: "#9C33CD")
    let blackColor = UIColor(hex: "#1B1B1B")
    let dayColor = UIColor(hex: "#A3A8B7")

    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var inviteBTN: UIButton!

    var myPendingImages = [Feed]()
    
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.delegate = self
        self.notificationsTableView.rowHeight = UITableView.automaticDimension
        self.notificationsTableView.estimatedRowHeight = UITableView.automaticDimension
        notificationsTableView.register(UINib(nibName: "NotificationFollowCell", bundle: nil), forCellReuseIdentifier: "NotificationFollowCell")
        notificationsTableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        notificationsTableView.register(UINib(nibName: "NotificationReplyCell", bundle: nil), forCellReuseIdentifier: "NotificationReplyCell")

        inviteBTN.onTap {
            self.openInviteScreen()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        APIManager.shared.getMyPendingImages(uid: currentUser!.uid) { (success, feeds, message) in
            if success{
                self.myPendingImages = feeds!
                self.photosCollectionView.reloadData()
            }else{
                self.myPendingImages.removeAll()
                self.photosCollectionView.reloadData()
            }
        }
        
        APIManager.shared.getMyNotifications(uid: currentUser!.uid) { (success, notifications, message
        ) in
            if success{
                self.notifications = notifications!
                self.notificationsTableView.reloadData()
            }else{
                self.notifications.removeAll()
                self.notificationsTableView.reloadData()
            }
        }
        
        APIManager.shared.updateBadgeCount(uid: currentUser!.uid, badge_count: 0) { (success, message) in
            currentUser?.badge_count = 0
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func openInviteScreen(){
        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "InviteController") as! InviteController
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func reply_to(user : User){
        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "CamController") as? CamController
        vc?.hidesBottomBarWhenPushed = true
        vc?.uploadingUser = user
        vc?.isPushing = true
        self.navigationController?.fadeTo(vc!)
    }
    
    func follow_at(index : Int){
        let selectedUser = notifications[index].opponentUser
        let cell = self.notificationsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as! NotificationFollowCell
        
        if selectedUser.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser.uid) { (success, message) in
                if success{
                    selectedUser.isFollowing = 1
                    cell.followBTN.setBackgroundImage(UIImage(named: "followed_button"), for: .normal)
                    cell.followBTN_Width.constant = cell.followedBtn_width

                    self.view.layoutIfNeeded()
                    APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Follow", body: "\(currentUser!.fullname) followed you.", badge_count: selectedUser.badge_count + 1)
                    APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                        
                    }
                }
            }
        }else{
            APIManager.shared.unfollowUser(first_uid: currentUser!.uid, second_uid: selectedUser.uid) { (success, message) in
                if success{
                    selectedUser.isFollowing = 0
                    cell.followBTN.setBackgroundImage(UIImage(named: "follow_button"), for: .normal)
                    cell.followBTN_Width.constant = cell.followBtn_width
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
}

extension NotificationsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.myPendingImages.count == 0) {
            self.photosCollectionView.setEmptyMessage("Nobody has sent a picture to your queue yet... This is awkward 🤷‍♂️😪")
        } else {
            self.photosCollectionView.restore()
        }
        return self.myPendingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let timeLabel = cell.viewWithTag(3) as! UILabel

        let selectedFeed = self.myPendingImages[indexPath.row]
        //        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"), placeholderImage: UIImage(named: "template"))
        photoImageView.load(photoUrl: "\(image_URL)\(selectedFeed.imageURL)", placeHolder: "")
        //        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"))
        nameLabel.text = "By \(selectedFeed.poster.fullname)"
        timeLabel.text = getTimeString(timestamp: selectedFeed.created_time)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 3) / 2
        let height = width * 9 / 10
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1{
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedNotification = self.notifications[indexPath.row]
        if selectedNotification.postType == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationFollowCell", for: indexPath) as! NotificationFollowCell
            cell.profileImageView.load(photoUrl: "\(image_URL)\(selectedNotification.opponentUser.profile_image_url)", placeHolder: "avatar")
            let postStr = " has followed you"
//            cell.headerLBL.text = selectedNotification.opponentUser.fullname + postStr
            cell.contentView.backgroundColor = .clear
        
            let text = selectedNotification.opponentUser.fullname.capitalized + postStr
            let attribText = text.withBoldText(text: selectedNotification.opponentUser.fullname.capitalized)
            cell.headerLBL.attributedText =  attribText
            cell.descLBL.text = getTimeString(timestamp: selectedNotification.time)
        
            cell.followBTN.onTap {
                self.follow_at(index: indexPath.row)
            }
            cell.check(isFollowing: selectedNotification.opponentUser.isFollowing ?? 0)
            cell.backgroundColor = .clear

            return cell
        }
        else if selectedNotification.postType == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationReplyCell", for: indexPath) as! NotificationReplyCell
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            let text = selectedNotification.opponentUser.fullname.capitalized + " uploaded to queue"
            let attribText = text.withBoldText(text: selectedNotification.opponentUser.fullname.capitalized, font: UIFont(name: "GalanoClassic-Regular", size: 13.44))
            cell.headerLBL.attributedText =  attribText
            cell.headerLBL.textColor = UIColor(red: 156/255.0, green: 51/255.0, blue: 205/255.0, alpha: 1.0)
            cell.profileImageView.load(photoUrl: "\(image_URL)\(selectedNotification.opponentUser.profile_image_url)", placeHolder: "avatar")
            cell.descLBL.text = getTimeString(timestamp: selectedNotification.time)
            cell.replyBTN.onTap {
                self.reply_to(user: selectedNotification.opponentUser)
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
            cell.contentView.backgroundColor = .clear
            var postStr = ""
            cell.headerLBL.textColor = UIColor(named: "MainBlack")
            postStr = " liked your photo"
            let text = selectedNotification.opponentUser.fullname.capitalized + postStr
            let attribText = text.withBoldText(text: selectedNotification.opponentUser.fullname.capitalized, font: UIFont(name: "GalanoClassic-Regular", size: 13.44))
            cell.headerLBL.attributedText =  attribText
            
            
            cell.profileImageView.load(photoUrl: "\(image_URL)\(selectedNotification.opponentUser.profile_image_url)", placeHolder: "avatar")
            
//            cell.headerLBL.text = selectedNotification.opponentUser.fullname + postStr
            
            let url = image_URL + (selectedNotification.feed?.imageURL ?? "")
            cell.feedImageView.load(photoUrl: url, placeHolder: "")
            cell.descLBL.text = getTimeString(timestamp: selectedNotification.time)
            cell.backgroundColor = .clear
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = backgroundWhite
        let label = UILabel()
        view.addSubview(label)
        if section == 0{
            label.text = "Today"
        }else{
            label.text = "Yesterday"
        }
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        label.textColor = mainGray
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = self.notifications[indexPath.row].opponentUser
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = selectedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRequestViewController") as! ConfirmRequestViewController
    //        contentVC.delegate = self
    //        let width = self.view.frame.width - 60
    //        let height = width * 1.4
    //        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
    //        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    //        popupVC.backgroundAlpha = 0.65
    //        popupVC.canTapOutsideToDismiss = true
    //        self.present(popupVC, animated: false, completion: nil)
    //    }
}

extension NotificationsViewController: ConfirmRequestViewControllerDelegate{
    func published() {
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        contentVC.delegate = self
        contentVC.result = 0
        let width = self.view.frame.width - 60
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
    
    func deleted() {
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        contentVC.delegate = self
        contentVC.result = 1
        let width = self.view.frame.width - 60
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
}

extension NotificationsViewController: ResultViewControllerDelegate{
    func done() {
        
    }
}
class GradientLabel: UILabel {
    var gradientColors: [CGColor] = []
    
    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }
    
    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }
        
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}

extension String {
    func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
        let _font = UIFont(name: "GalanoClassic-Regular", size: 13.44)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font!])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFont.SemiBold.size(13.44)]
        let range = (self as NSString).range(of: text)
        fullString.addAttributes(boldFontAttribute, range: range)
        return fullString
    }
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
