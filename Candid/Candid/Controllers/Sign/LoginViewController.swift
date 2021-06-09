//
//  LoginViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let shadow = gradient(view: self.loginButton, radius: 20)
        self.loginButton.layer.addSublayer(shadow)
        usernameTextfield.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        passwordTextfield.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadow = gradient(view: self.loginButton, radius: 20)
        self.loginButton.layer.addSublayer(shadow)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if usernameTextfield.text == ""{
            self.view.makeToast("Please enter username")
            return
        }
        
        if passwordTextfield.text == ""{
            self.view.makeToast("Please enter password")
            return
        }
        
        self.view.endEditing(true)
        
        APIManager.shared.login(username: usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), password: passwordTextfield.text!, token: token ?? "") { (success, user, message) in
            if success{
                
                
                UserDefaults.standard.setValue(self.usernameTextfield.text!.replacingOccurrences(of: "@", with: ""), forKey: "username")
                UserDefaults.standard.setValue(self.passwordTextfield.text!, forKey: "password")
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
    
    @IBAction func signupButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    

}
