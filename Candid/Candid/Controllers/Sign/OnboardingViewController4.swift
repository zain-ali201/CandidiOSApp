//
//  OnboardingViewController4.swift
//  Candid
//
//  Created by Administrator-KHR on 2021/4/14.
//

import UIKit

class OnboardingViewController4: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadow = gradient(view: self.nextButton, radius: 20)
        self.nextButton.layer.addSublayer(shadow)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    

    

}
