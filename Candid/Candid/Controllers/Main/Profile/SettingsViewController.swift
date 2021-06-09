//
//  SettingsViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func followingButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followersButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editProfileButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func faqButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func privacyButtonClicked(_ sender: UIButton) {
        if let url = URL(string: "https://wearecandidapp.wixsite.com/my-site-1/privacypolicy") {
//            UIApplication.shared.open(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func reportButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "username")
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController: UIGestureRecognizerDelegate{
}
