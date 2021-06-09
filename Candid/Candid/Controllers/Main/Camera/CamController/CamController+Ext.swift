//
//  CamController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit

// UI Animations
extension CamController {
    
    func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
        }
    }
    
    func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
        }
    }
    
    func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto{
            flashMode = .on
            flashButton.setImage(UIImage(named: "flash"), for: UIControl.State())
        }else if flashMode == .on{
            flashMode = .off
            flashButton.setImage(UIImage(named: "flashOutline"), for: UIControl.State())
        }else if flashMode == .off{
            flashMode = .auto
            flashButton.setImage(UIImage(named: "flashauto"), for: UIControl.State())
        }
    }
}



