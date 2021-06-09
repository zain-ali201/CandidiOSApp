//
//  ProfileViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!

    @IBOutlet weak var photosCollectionView: UICollectionView!
 
    var images = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeToPop()


        
        self.uploadButton.onTap {
            self.uploadAction()
        }
        // Do any additional setup after loading the view.
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
    func uploadAction(){
        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "CamController") as? CamController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isPushing = true
        self.navigationController?.fadeTo(vc!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fullnameLabel.text = currentUser?.fullname
        self.usernameLabel.text = "@\(currentUser?.username ?? "")"
        self.bioLabel.text = currentUser?.bio == "" ? "Bio" : currentUser?.bio
//        self.profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(currentUser?.profile_image_url ?? "")"), placeholderImage: UIImage(named: "avatar"))
        self.profileImageView.load(photoUrl: "\(image_URL)\(currentUser?.profile_image_url ?? "")", placeHolder: "avatar")
        APIManager.shared.getMyImages(uid: currentUser!.uid) { (success, feeds, message) in
            if success{
                self.images = feeds!
                self.photosCollectionView.reloadData()
            }else{
                self.images.removeAll()
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func moreButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    

}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.images.count == 0) {
            self.photosCollectionView.setEmptyMessage("Go to your queue (notification tab) and post a pic 💩")
        } else {
            self.photosCollectionView.restore()
        }
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let selectedFeed = self.images[indexPath.row]
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"), placeholderImage: UIImage(named: "template"))
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed.imageURL)"))
        nameLabel.text = "By \(selectedFeed.poster.fullname)"
        photoImageView.load(photoUrl: "\(image_URL)\(selectedFeed.imageURL)", placeHolder: "")
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
        vc.isMyProfile = true
        vc.selectedUser = currentUser
        vc.feeds = self.images
        vc.selectedIndex = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
//        vc.isMyProfile = true
//        vc.selectedFeed = self.images[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1{
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        view.backgroundColor = .clear
        let messageLabel = UILabel(frame: CGRect(x: 50, y: 50, width: self.bounds.size.width - 100, height: self.bounds.size.height - 100))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
//        messageLabel.sizeToFit()
        view.addSubview(messageLabel)

        self.backgroundView = view
    }

    func restore() {
        self.backgroundView = nil
    }
}


extension ProfileViewController: UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
                return false
            }
        return true
    }
}

