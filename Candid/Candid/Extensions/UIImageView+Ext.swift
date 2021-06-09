//
//  UIImageView+Ext.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit
import Kingfisher

extension UIImageView {

    
    func load(photoUrl:String ,placeHolder : String){
    
           
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        var placeHolderImage = UIImage()
        if placeHolder.count > 0{
            placeHolderImage = UIImage(named: placeHolder) ?? UIImage()
        }

        if let url = URL(string: photoUrl), url.host != nil {
            
            var kf = self.kf
            kf.indicatorType = .activity
            self.kf.setImage(
                with: url,
                placeholder: placeHolderImage,
                options: [
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
//                switch result {
//                case .success(let value):
//                    //self.image = value.image
//                case .failure(let error):
//                    print("Job failed: \(error.localizedDescription)")
//                }
            }
        }else{
            self.image = placeHolderImage
        }
    }

    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width :size.width * heightRatio, height :size.height * heightRatio)
        } else {
            newSize = CGSize(width :size.width * widthRatio,  height :size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }

}
extension UIViewController{
    func showToast(message : String){
        if var topController = UIApplication.shared.windows.first!.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.view.hideAllToasts()
            topController.view.makeToast(message)
        }
    }
}
