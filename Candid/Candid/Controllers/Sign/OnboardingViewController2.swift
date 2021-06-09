//
//  OnboardingViewController2.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class OnboardingViewController2: UIViewController {

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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController4") as! OnboardingViewController4
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    

}
