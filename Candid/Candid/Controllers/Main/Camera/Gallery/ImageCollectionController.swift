//
//  ImageCollectionController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit
import EzPopup
import SVProgressHUD

class ImageCollectionController: UIViewController {
    private var numberOfItemsInRow = 2
    private var minimumSpacing = 5
    private var edgeInsetPadding = 10
    var uploadingUser : User?
    var lastImage = UIImage()
    @IBOutlet var collector : UICollectionView!{
        didSet{
            collector.dataSource = self
            collector.delegate = self
        }
    }
    var imagesArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collector.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    @IBAction func saveActiom(_ sender: Any) {
        for image in imagesArray{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        self.showToast(message: "Images saved to your photo library")
        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func deleteAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
        
        var delStr = ""
        if imagesArray.count > 1{
            delStr = "Remove all images"
        }else{
            delStr = "Remove Image"
        }
        
        let delAction = UIAlertAction(title: delStr, style: .default) { (action) in
            self.imagesArray.removeAll()
            self.collector.reloadData()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(delAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
   
    }
    @IBAction func selectAction(_ sender: Any) {
        if uploadingUser == nil{
            let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppUsersController") as? AppUsersController
            vc?.imageArray = imagesArray
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            let myGroup = DispatchGroup()
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
            for i in 0 ..< imagesArray.count{
                myGroup.enter()
                let image = imagesArray[i]
                let randomInt = Int.random(in: 1..<10)
                let nameAppend = "_\(randomInt)_\(i+1)"
                let imageName = "\(currentUser!.uid)\(Int(Date().timeIntervalSince1970))\(nameAppend).jpg"

                lastImage = image
                self.upload(image: image, imageName: imageName, selectedUser: uploadingUser!) { success in
                    print("Finished request \(i)")
                    myGroup.leave()
                }
            }
            
            myGroup.notify(queue: .main) {
                SVProgressHUD.dismiss()
                self.imagesArray.removeAll()
                self.collector.reloadData()
                self.showAlert()
                print("Finished all requests.")
            }
        }
     
    }
    
    func showAlert(){
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "SentDoneViewController") as! SentDoneViewController
        contentVC.delegate = self
        contentVC.fullname = uploadingUser?.fullname
        contentVC.takenPhoto = lastImage
        let width = self.view.frame.width - 60
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
    
    
    
    func  upload(image : UIImage,imageName : String,selectedUser : User, completion: @escaping(_ sucess: Bool) -> Void){
        APIManager.shared.uploadImage(image: image, imageName: imageName) { (success) in
            if success{
                APIManager.shared.submitRequest(owner_uid: self.uploadingUser?.uid ?? 0, imageURL: imageName, poster_uid: currentUser!.uid, isApproved: 0) { (success, fid, message) in
                    if success{
                        APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Share", body: "\(currentUser!.fullname) sent a photo to your queue", badge_count: selectedUser.badge_count + 1)
                        APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                            
                        }
                    }
                    completion(success)
                }
            }else{
                self.view.makeToast("Something went wrong. Try again later.")
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

extension ImageCollectionController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let width = (Int(UIScreen.main.bounds.size.width) - (numberOfItemsInRow - 1) * minimumSpacing - edgeInsetPadding) / numberOfItemsInRow
        cell.imgView.image = self.resizeImage(image: imagesArray[indexPath.row], newWidth: CGFloat(width))
        
        return cell
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
extension ImageCollectionController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,SentDoneViewControllerDelegate{
    func done() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (Int(UIScreen.main.bounds.size.width) - (numberOfItemsInRow - 1) * minimumSpacing - edgeInsetPadding) / numberOfItemsInRow
//        return CGSize(width: width, height: width)
        
        let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            return CGSize(width: (screenWidth/3)-6, height: (screenWidth/3)-6);
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Take an action", message: nil, preferredStyle: .actionSheet)
      
        let delAction = UIAlertAction(title: "Delete selected image", style: .default) { (action) in
            self.imagesArray.remove(at: indexPath.row)
            self.collector.reloadData()
            
            if self.imagesArray.count == 0{
                self.navigationController?.popViewController(animated:true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(delAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return CGFloat(minimumSpacing)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return CGFloat(minimumSpacing)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let inset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        edgeInsetPadding = Int(inset.left+inset.right)
//        return inset
//    }
}
