//
//  AppUsersController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit
import EzPopup

class AppUsersController: UIViewController {

    var imageArray = [UIImage]()
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!

    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var loaderView: UIView!{
        didSet{
            loaderView.alpha = 0
        }
    }
    @IBOutlet weak var collectionBottom: NSLayoutConstraint!
    var lastImage = UIImage()
    var uploadUser : User?
    @IBOutlet weak var usersTableView: UITableView!{
        didSet{
            usersTableView.dataSource = self
            usersTableView.delegate = self
            usersTableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var imageCollection: UICollectionView!{
        didSet{
            imageCollection.dataSource = self
            imageCollection.delegate = self
            imageCollection.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        }
    }
    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.delegate = self
        }
    }

    var allUsers = [User]()
    var searchedUsers = [User]()
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.textColor = .black
        loadingLabel.font = AppFont.SemiBold.size(16)
        activity.color = .black
        
        self.activity.alpha = 0
        self.loadingLabel.alpha = 0
        lastImage = imageArray.last ?? UIImage()
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Type to search", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        // Do any additional setup after loading the view.
     
        self.getUsers()
        self.swipeToPop()
    }
    
    func getUsers(){
        APIManager.shared.getUsers(uid: currentUser!.uid, loader: true) { (success, users, message) in
            if success{
                self.setArray_Data(users: users)
            }
        }
    }
    
    func setArray_Data(users : [User]){
        self.allUsers = users
        self.searchedUsers = []
        self.searchActive = false
        self.usersTableView.reloadData {
            
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
    
    func upload(image : UIImage,imageName : String,selectedUser : User, completion: @escaping(_ sucess: Bool) -> Void){
        APIManager.shared.uploadImage(image: image, imageName: imageName) { (success) in
            if success{
                APIManager.shared.submitRequest(owner_uid: selectedUser.uid, imageURL: imageName, poster_uid: currentUser!.uid, isApproved: 0) { (success, fid, message) in
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
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.imageCollection.alpha = 0.5
        self.activity.alpha = 1
        self.loadingLabel.alpha = 1
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.usersTableView.indexPath(for: cell)!
        if searchActive{
            uploadUser = self.searchedUsers[indexPath.row]
        }else{
            uploadUser = self.allUsers[indexPath.row]
        }
        let myGroup = DispatchGroup()
        
        for i in 0 ..< imageArray.count{
            myGroup.enter()
            let image = imageArray[i]
            let randomInt = Int.random(in: 1..<10)
            let nameAppend = "_\(randomInt)_\(i+1)"
            let imageName = "\(currentUser!.uid)\(Int(Date().timeIntervalSince1970))\(nameAppend).jpg"


            self.upload(image: image, imageName: imageName, selectedUser: uploadUser!) { success in
                print("Finished request \(i)")
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            self.imageArray.removeAll()
            self.imageCollection.reloadData()
            self.collectionHeight.constant = 0
            self.collectionBottom.constant = 0
            self.activity.alpha = 0
            self.loadingLabel.alpha = 0
            self.imageCollection.alpha = 1
            self.showAlert()
            print("Finished all requests.")
        }
    }
    
    
    func showAlert(){
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "SentDoneViewController") as! SentDoneViewController
        contentVC.delegate = self
        contentVC.fullname = uploadUser?.fullname
        contentVC.takenPhoto = lastImage
        let width = self.view.frame.width - 60
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
    
    
    
    func popTo_Cam(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CamController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func searchUser(keyword: String){
        if keyword.count == 0{
            self.searchActive = false
            self.searchedUsers.removeAll()
            self.setArray_Data(users: self.allUsers)
            self.usersTableView.reloadData()
        }else{
            self.addField_Indicator()
            self.searchActive = true
            self.searchedUsers.removeAll()
            self.usersTableView.reloadData()
            APIManager.shared.searchUsers(uid: currentUser!.uid, keyword: keyword) { (success, users, message) in
                self.searchedUsers = users
                self.usersTableView.reloadData()
                self.removeField_Indicator()
            }
        }
    }

    func addField_Indicator(){
        let _activityHolder = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        let _activityIndicator = UIActivityIndicatorView(style: .gray)
        searchTextField.rightViewMode = UITextField.ViewMode.always
        _activityIndicator.startAnimating()
        _activityIndicator.backgroundColor = UIColor.clear
        _activityIndicator.center = CGPoint(x: _activityHolder.frame.size.width/2, y: _activityHolder.frame.size.height/2)
        _activityHolder.addSubview(_activityIndicator)
        searchTextField.rightView = _activityHolder
    }
    func removeField_Indicator(){
        searchTextField.rightView = nil
    }
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


}
extension AppUsersController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return self.searchedUsers.count
        }else{
            return self.allUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")!
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
   
        var selectedCellUser : User?
        if searchActive{
            selectedCellUser = self.searchedUsers[indexPath.row]
        }else{
            selectedCellUser = self.allUsers[indexPath.row]
        }
        
        if selectedCellUser != nil{
            photoImageView.load(photoUrl: "\(image_URL)\(selectedCellUser?.profile_image_url ?? "")", placeHolder: "avatar")
            nameLabel.text = selectedCellUser?.fullname
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCellUser : User?
        if searchActive{
            selectedCellUser = self.searchedUsers[indexPath.row]
        }else{
            selectedCellUser = self.allUsers[indexPath.row]
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        vc.selectedUser = selectedCellUser
        vc.selectedPath = indexPath
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AppUsersController: SentDoneViewControllerDelegate,OtherProfileDelegate{
    func uploadApproved(user:  User,atIndex : IndexPath) {
        self.view.endEditing(true)
        self.imageCollection.alpha = 0.5
        self.activity.alpha = 1
        self.loadingLabel.alpha = 1
        if searchActive{
            uploadUser = self.searchedUsers[atIndex.row]
        }else{
            uploadUser = self.allUsers[atIndex.row]
        }
        let myGroup = DispatchGroup()
        
        for i in 0 ..< imageArray.count{
            myGroup.enter()
            let image = imageArray[i]
            let randomInt = Int.random(in: 1..<10)
            let nameAppend = "_\(randomInt)_\(i+1)"
            let imageName = "\(currentUser!.uid)\(Int(Date().timeIntervalSince1970))\(nameAppend).jpg"


            self.upload(image: image, imageName: imageName, selectedUser: uploadUser!) { success in
                print("Finished request \(i)")
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            self.imageArray.removeAll()
            self.imageCollection.reloadData()
            self.collectionHeight.constant = 0
            self.collectionBottom.constant = 0
            self.activity.alpha = 0
            self.loadingLabel.alpha = 0
            self.imageCollection.alpha = 1
            self.showAlert()
            print("Finished all requests.")
        }
    }
    
    func done() {
        self.popTo_Cam()
    }
}

extension AppUsersController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedTextString : NSString = textField.text! as NSString
        updatedTextString = updatedTextString.replacingCharacters(in: range, with: string) as NSString
        
        print(updatedTextString)
        
        self.searchUser(keyword: updatedTextString as String)
//        if let char = string.cString(using: .utf8){
//            let isBackSpace = strcmp(char, "\\b")
//            if (isBackSpace == -92){
//                if textField.text?.count == 0 || textField.text?.count == 1{
//                    self.foundUsers.removeAll()
//                    self.foundUsers = self.users
//                    self.usersTableView.reloadData()
//                }else{
//                    let keyword = String(textField.text!.dropLast())
//                    self.searchUser(keyword: keyword)
//                }
//            }else{
//                let keyword = "\(textField.text ?? "")\(string)"
//                self.searchUser(keyword: keyword)
//            }
//        }
        return true
    }
}

extension AppUsersController: UIGestureRecognizerDelegate{
    
}
extension AppUsersController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let img = cell.imgView.ResizeImage(image: imageArray[indexPath.row], targetSize: CGSize(width: 90, height: 90))
        cell.imgView.image = img
        cell.imgView.contentMode = .scaleAspectFill
        
        return cell
    }
}
extension AppUsersController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

