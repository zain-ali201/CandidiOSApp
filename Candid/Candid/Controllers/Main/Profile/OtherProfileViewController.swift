//
//  OtherProfileViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

protocol OtherProfileDelegate: AnyObject{
    func uploadApproved(user:  User,atIndex : IndexPath)
}

class OtherProfileViewController: UIViewController {
    weak var delegate: OtherProfileDelegate?

    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var uploadButton: UIButton!

    var selectedUser: User?
    var images = [Feed]()
    var selectedPath = IndexPath(row: 0, section: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uploadButton.onTap {
            self.uploadAction()
        }
        // Do any additional setup after loading the view.
        self.swipeToPop()
    }
    func uploadAction(){
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
             let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            
            if viewController is AppUsersController{
                print(navController.viewControllers)
                
                self.delegate?.uploadApproved(user: self.selectedUser!, atIndex: self.selectedPath)
                self.navigationController?.popViewController(animated: true)
            }else{
                self.openCamera()
            }
        }else{
            self.openCamera()
        }
    }
    
    
    func openCamera(){
        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "CamController") as? CamController
        vc?.hidesBottomBarWhenPushed = true
        vc?.uploadingUser = self.selectedUser
        vc?.isPushing = true
        self.navigationController?.fadeTo(vc!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fullnameLabel.text = selectedUser?.fullname
        self.usernameLabel.text = "@\(selectedUser?.username ?? "")"
        self.bioLabel.text = selectedUser?.bio == "" ? "Bio" : selectedUser?.bio
        self.profileImageView.load(photoUrl: "\(image_URL)\(selectedUser?.profile_image_url ?? "")", placeHolder: "avatar")
//        self.profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedUser?.profile_image_url ?? "")"), placeholderImage: UIImage(named: "avatar"))
        self.followButton.setImage(selectedUser!.isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
        APIManager.shared.getMyImages(uid: selectedUser!.uid) { (success, feeds, message) in
            if success{
                self.images = feeds!
                self.photosCollectionView.reloadData()
            }else{
                self.images.removeAll()
                self.photosCollectionView.reloadData()
            }
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

    @IBAction func followButtonClicked(_ sender: UIButton) {
        if selectedUser!.isFollowing == 0{
            APIManager.shared.followUser(first_uid: currentUser!.uid, second_uid: selectedUser!.uid) { (success, message) in
                if success{
                    self.selectedUser?.isFollowing = 1
                    self.followButton.setImage(UIImage(named: "followed_button"), for: .normal)
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
                    self.followButton.setImage(UIImage(named: "follow_button"), for: .normal)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @IBAction func blockButtonClicked(_ sender: UIButton) {
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
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OtherProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let selectedFeed = self.images[indexPath.row]
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"), placeholderImage: UIImage(named: "template"))
        photoImageView.load(photoUrl: "\(image_URL)\(selectedFeed.imageURL)", placeHolder: "")
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"))
        nameLabel.text = "By \(selectedFeed.poster.fullname)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 3) / 2
        let height = width * 1.4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserFeedsController") as! UserFeedsController
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        vc.isMyProfile = false
        vc.selectedUser = self.selectedUser
        vc.feeds = self.images
        vc.selectedIndex = indexPath
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

extension OtherProfileViewController: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
                return false
            }
        return true
    }
}
extension UINavigationController {
    func popViewControllerWithHandler(completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
    func pushViewController(viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}
