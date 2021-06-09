//
//  SignupViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import GrowingTextView

class SignupViewController: UIViewController ,GrowingTextViewDelegate{

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var fullnameTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pageButton: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var bioTextView: GrowingTextView!{
        didSet{
            bioTextView.placeholder = "Write your bio"
            bioTextView.placeholderColor = .lightGray
            bioTextView.delegate = self
            bioTextView.font = AppFont.Medium.size(18)
        }
    }

    var imageURL: String?
    
    var formCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formCount = 0
        // Do any additional setup after loading the view.
        let shadow = gradient(view: self.signupButton, radius: 20)
        self.signupButton.layer.addSublayer(shadow)
        fullnameTextfield.attributedPlaceholder = NSAttributedString(string: "Full name", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        usernameTextfield.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        passwordTextfield.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        phonenumberTextfield.attributedPlaceholder = NSAttributedString(string: "Phone number", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        
        signupButton.setTitle("Next", for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadow = gradient(view: self.signupButton, radius: 20)
        self.signupButton.layer.addSublayer(shadow)
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print(height)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsButtonClicked(_ sender: UIButton) {
        if let url = URL(string: "https://wearecandidapp.wixsite.com/my-site-1") {
//            UIApplication.shared.open(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func signupButtonClicked(_ sender: UIButton) {
        if fullnameTextfield.text == ""{
            self.view.makeToast("Please enter full name")
            return
        }
        if usernameTextfield.text == ""{
            self.view.makeToast("Please enter username")
            return
        }
        if passwordTextfield.text == ""{
            self.view.makeToast("Please enter password")
            return
        }
        if phonenumberTextfield.text == ""{
            self.view.makeToast("Please enter phone number")
            return
        }
        
        self.view.endEditing(true)
        let width = UIScreen.main.bounds.size.width
        if formCount == 0{
            formCount = 1
            pageButton.setImage(UIImage(named: "page2"), for: .normal)
            mainScrollView.setContentOffset(CGPoint(x: width - 60, y: 0), animated: true)
            signupButton.setTitle("Next", for: .normal)
            return
        }else if formCount == 1{
            formCount = 2
            pageButton.setImage(UIImage(named: "page3"), for: .normal)
            mainScrollView.setContentOffset(CGPoint(x: 2 * (width - 60), y: 0), animated: true)
            signupButton.setTitle("Sign up", for: .normal)
            return
        }
        
        APIManager.shared.registerUser(fullname: fullnameTextfield.text!, username: usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), password: passwordTextfield.text!, phoneNumber: phonenumberTextfield.text!, token: token ?? "", bio: self.bioTextView.text ?? "", profile_image_url: imageURL ?? "") { (success, uid, message) in
            if success{
                UserDefaults.standard.setValue(self.usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), forKey: "username")
                UserDefaults.standard.setValue(self.passwordTextfield.text!, forKey: "password")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
                vc.uid = uid
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.view.makeToast(message)
                self.formCount = 0
                self.pageButton.setImage(UIImage(named: "page1"), for: .normal)
                self.mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.signupButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    func updateBio(){
        APIManager.shared.updateProfile(id: currentUser!.uid, fullname: self.fullnameTextfield.text ?? "", username: self.usernameTextfield.text ?? "", bio: self.bioTextView.text ?? "", profile_image_url: self.imageURL ?? "", loader: false) { (success, message) in
        }
    }
    
    @IBAction func pageButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if mainScrollView.contentOffset.x == 0{
            pageButton.setImage(UIImage(named: "page5"), for: .normal)
            mainScrollView.setContentOffset(CGPoint(x: mainScrollView.frame.width, y: 0), animated: true)
        }else{
            pageButton.setImage(UIImage(named: "page4"), for: .normal)
            mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    @IBAction func imageButtonClicked(_ sender: UIButton) {
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
}

extension SignupViewController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageButton.setImage(UIImage(named: "page\(pageNumber + 1)"), for: .normal)

        /*if pageNumber == 0{
            pageButton.setImage(UIImage(named: "page4"), for: .normal)
        }else{
            pageButton.setImage(UIImage(named: "page5"), for: .normal)
        }*/
    }
}

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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



////// 600+714+849.66+1011+1203+1431.57+1703.56+2027.23+2412.40 === 24

//////600+780+1014+1318+1713+2226



