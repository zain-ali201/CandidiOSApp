//
//  SentDoneViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

protocol SentDoneViewControllerDelegate: AnyObject{
    func done()
}

class SentDoneViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var queueLabel: UILabel!
    
    weak var delegate: SentDoneViewControllerDelegate?
    
    var fullname: String?
    var takenPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let firstName = self.fullname!.components(separatedBy: " ")[0]
        sentLabel.text = "Sent to \(firstName)!"
        queueLabel.text = "Your photo has been sent to \(firstName)'s queue"
        photoImageView.image = self.takenPhoto
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.done()
        }
    }
    
    

}
