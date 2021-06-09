//
//  VerificationViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class VerificationViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var verificationTextfield: UITextField!
    
    var uid: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let shadow = gradient(view: self.confirmButton, radius: 20)
        self.confirmButton.layer.addSublayer(shadow)
        verificationTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Verification Code", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadow = gradient(view: self.confirmButton, radius: 20)
        self.confirmButton.layer.addSublayer(shadow)
    }
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        if verificationTextfield.text == ""{
            self.view.makeToast("Please enter the verification code")
            return
        }
        
        self.view.endEditing(true)
        
        APIManager.shared.confirmVerificationCode(id: uid!, verificationCode: verificationTextfield.text!) { (success, user, message) in
            if success{
                UserDefaults.standard.setValue(user!.uid, forKey: "userID")
                currentUser = user
                let storyboard = UIStoryboard(name: "Feature", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)
            }else{
                self.view.makeToast(message)
            }
        }
        
    }
    

    

}
