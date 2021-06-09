//
//  NotificationReplyCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//


import UIKit

class NotificationReplyCell: UITableViewCell {

    @IBOutlet var headerLBL : UILabel!
    @IBOutlet var descLBL : UILabel!
    @IBOutlet var profileImageView : UIImageViewX!
    @IBOutlet var replyBTN : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        descLBL.font = UIFont(name: "GalanoClassic-Regular", size: 11)
        headerLBL.font = UIFont(name: "GalanoClassic-Regular", size: 13.44)
        descLBL.textColor = UIColor(named: "MainGray")

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
