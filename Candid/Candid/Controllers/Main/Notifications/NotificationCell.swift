//
//  NotificationCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet var headerLBL : UILabel!
    @IBOutlet var descLBL : UILabel!
    @IBOutlet var profileImageView : UIImageViewX!
    @IBOutlet var feedImageView : UIImageViewX!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        headerLBL.font = UIFont(name: "GalanoClassic-Regular", size: 13.44)
        headerLBL.addCharacterSpacing(kernValue: 0.2)
        descLBL.font = UIFont(name: "GalanoClassic-Regular", size: 11)

        
        descLBL.textColor = UIColor(named: "MainGray")
        headerLBL.textColor = UIColor(named: "MainBlack")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UILabel {
  func addCharacterSpacing(kernValue: Double = 1.15) {
    if let labelText = text, labelText.count > 0 {
      let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
      attributedText = attributedString
    }
  }
}
