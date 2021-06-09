//
//  PhotosViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import EzPopup

class PhotosViewController: UIViewController {

    @IBOutlet weak var photosCollectionView: UICollectionView!

    var myPendingImages = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        APIManager.shared.getMyPendingImages(uid: currentUser!.uid) { (success, feeds, message) in
            if success{
                self.myPendingImages = feeds!
                self.photosCollectionView.reloadData()
            }else{
                self.myPendingImages.removeAll()
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    

}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        let height = width * 1.4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRequestViewController") as! ConfirmRequestViewController
        contentVC.delegate = self
        contentVC.feed = self.myPendingImages[indexPath.row]
        let width = self.view.frame.width - 60
        let height = width * 1.4
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1{
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension PhotosViewController: ConfirmRequestViewControllerDelegate{
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

extension PhotosViewController: ResultViewControllerDelegate{
    func done() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PhotosViewController: UIGestureRecognizerDelegate{
    
}
