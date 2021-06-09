//
//  ImageCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imgView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.backgroundColor = .clear
        // Initialization code
    }


}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
