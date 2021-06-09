//
//  FullImageViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/28.
//

import UIKit

class FullImageViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageView: EEZoomableImageView!{
        didSet{
            imageView.minZoomScale = 0.5
            imageView.maxZoomScale = 3.0
            imageView.resetAnimationDuration = 0.5
        }
    }
    var isMyProfile = true
    
    var selectedFeed: Feed?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.deleteButton.isHidden = !isMyProfile
//        imageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed!.imageURL)"), placeholderImage: UIImage(named: "template"))
        imageView.load(photoUrl: "\(image_URL)\(selectedFeed!.imageURL)", placeHolder: "")
//        imageView.sd_setImage(with: URL(string: "\(image_URL)\(selectedFeed!.imageURL)"))
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
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        APIManager.shared.deleteImage(fid: selectedFeed!.fid) { (success, message) in
            if success{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.view.makeToast(message)
            }
        }
        
    }
    
    

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FullImageViewController: UIGestureRecognizerDelegate{
    
}
