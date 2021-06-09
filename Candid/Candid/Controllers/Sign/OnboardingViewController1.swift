//
//  OnboardingViewController1.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class OnboardingViewController1: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any aditional setup after loading the view.
//        nextButton.layer.borderColor = borderColor.cgColor
        
        
//        let mainShadow = gradient(view: self.view, radius: UIWindow().layer.cornerRadius)
//        self.view.layer.addSublayer(mainShadow)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadow = gradient(view: self.nextButton, radius: 20)
        self.nextButton.layer.addSublayer(shadow)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController2") as! OnboardingViewController2
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    

}
