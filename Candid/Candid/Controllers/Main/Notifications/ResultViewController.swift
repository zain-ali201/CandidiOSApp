//
//  ResultViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

protocol ResultViewControllerDelegate: class{
    func done()
}

class ResultViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: ResultViewControllerDelegate?
    
    var result = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if result == 1{
            resultLabel.text = "Deleted!"
            descriptionLabel.text = "Your photo has successfully been deleted"
        }
    }
    

    

    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.done()
        }
    }
}
