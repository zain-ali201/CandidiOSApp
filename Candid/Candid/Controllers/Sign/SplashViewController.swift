//
//  SplashViewController.swift
//  Candid
//
//  Created by Administrator-KHR on 2021/4/12.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let username = UserDefaults.standard.value(forKey: "username") as? String{
            let password = UserDefaults.standard.value(forKey: "password") as! String
            APIManager.shared.login(username: username, password: password, token: token ?? "") { (success, user, message) in
                if success{
                    UserDefaults.standard.setValue(user!.uid, forKey: "userID")
                    currentUser = user
                    let storyboard = UIStoryboard(name: "Feature", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }else{
                    self.view.makeToast(message)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController1") as! OnboardingViewController1
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController1") as! OnboardingViewController1
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    

    
}
