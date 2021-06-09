//
//  ConfirmRequestViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
protocol ConfirmRequestViewControllerDelegate: class{
    func published()
    func deleted()
}

class ConfirmRequestViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var feed: Feed?
    
    weak var delegate: ConfirmRequestViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(feed!.imageURL)"), placeholderImage: UIImage(named: "template"))
        photoImageView.load(photoUrl: "\(image_URL)\(feed!.imageURL)", placeHolder: "")
//        photoImageView.sd_setImage(with: URL(string: "\(image_URL)\(feed!.imageURL)"))
        usernameLabel.text = "By \(feed!.poster.fullname)"
        timeLabel.text = getTimeString(timestamp: feed!.created_time)
    }
    
    @IBAction func publishButtonClicked(_ sender: UIButton) {
        APIManager.shared.approveRequest(fid: feed!.fid) { (success, message) in
            if success{
                self.dismiss(animated: true) {
                    self.delegate?.published()
                }
            }else{
                self.view.makeToast(message)
            }
        }
        
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        APIManager.shared.deleteImage(fid: feed!.fid) { (success, message) in
            if success{
                self.dismiss(animated: true) {
                    self.delegate?.deleted()
                }
            }else{
                self.view.makeToast(message)
            }
        }
        
    }
    

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
