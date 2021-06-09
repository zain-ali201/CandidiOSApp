//
//  EditProfileViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var images = [Feed]()
    
    var imageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fullnameTextField.attributedPlaceholder = NSAttributedString(string: "Enter Name", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        usernameTextfield.attributedPlaceholder = NSAttributedString(string: "@username", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        
        self.fullnameTextField.text = currentUser?.fullname
        self.usernameTextfield.text = "@\(currentUser?.username ?? "")"
        self.bioTextView.text = currentUser?.bio == "" ? "Bio" : currentUser?.bio
        self.profileImageView.load(photoUrl: "\(image_URL)\(currentUser?.profile_image_url ?? "")", placeHolder: "avatar")
//        self.profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(currentUser?.profile_image_url ?? "")"), placeholderImage: UIImage(named: "avatar"))
        self.imageURL = currentUser?.profile_image_url
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
    
    @IBAction func editPictureButtonClicked(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (action) in
            let pickerVC = UIImagePickerController()
            pickerVC.sourceType = .camera
            pickerVC.mediaTypes = ["public.image"]
            pickerVC.delegate = self
            pickerVC.modalPresentationStyle = .fullScreen
            self.present(pickerVC, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { (action) in
            let pickerVC = UIImagePickerController()
            pickerVC.sourceType = .photoLibrary
            pickerVC.mediaTypes = ["public.image"]
            pickerVC.delegate = self
            pickerVC.modalPresentationStyle = .fullScreen
            self.present(pickerVC, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Do you want to save profile before leaving this page?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            if self.fullnameTextField.text == ""{
                self.view.makeToast("Please enter full name")
                return
            }
            
            if self.usernameTextfield.text == ""{
                self.view.makeToast("Please enter username")
                return
            }
            
            APIManager.shared.updateProfile(id: currentUser!.uid, fullname: self.fullnameTextField.text!, username: self.usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), bio: self.bioTextView.text!, profile_image_url: self.imageURL!, loader: true) { (success, message) in
                if success{
                    currentUser?.fullname = self.fullnameTextField.text!
                    currentUser?.username = self.usernameTextfield.text!.replacingOccurrences(of: "@", with: "")
                    currentUser?.bio = self.bioTextView.text!
                    currentUser?.profile_image_url = self.imageURL!
                    UserDefaults.standard.setValue(self.usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), forKey: "username")
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.view.makeToast(message)
                }
            }
            
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    

}

extension EditProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        vc.isMyProfile = true
        vc.selectedFeed = self.images[indexPath.row]
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

extension EditProfileViewController: UIGestureRecognizerDelegate{
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let imageName = "user\(timestamp).jpg"
        APIManager.shared.uploadImage(image: image, imageName: imageName) { (success) in
            if success{
                self.imageURL = imageName
                self.profileImageView.image = image
                picker.dismiss(animated: true, completion: nil)
            }else{
                self.view.makeToast("Something went wrong. Try again later.")
                print("error")
            }
        }
    }
}
