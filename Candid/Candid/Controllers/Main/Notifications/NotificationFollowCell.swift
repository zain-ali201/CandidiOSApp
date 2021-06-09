//
//  NotificationFollowCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit

class NotificationFollowCell: UITableViewCell {
    
    @IBOutlet var headerLBL : GradientLabel!
    @IBOutlet var descLBL : UILabel!
    @IBOutlet var profileImageView : UIImageViewX!
    @IBOutlet var followBTN : UIButton!
    @IBOutlet var followBTN_Width : NSLayoutConstraint!

    let followBtn_width : CGFloat = 81.0
    let followedBtn_width : CGFloat = 94.0
    
    override func awakeFromNib() {
        self.selectionStyle = .none
        descLBL.font = UIFont(name: "GalanoClassic-Regular", size: 11)
        headerLBL.font = UIFont(name: "GalanoClassic-Regular", size: 13.44)
        descLBL.textColor = UIColor(named: "MainGray")
        headerLBL.addCharacterSpacing(kernValue: 0.2)

        let color1 = UIColor(red: 224/255.0,green: 32/255.0, blue: 32/255.0, alpha: 1.0).cgColor
        let color2 = UIColor(red: 250/255.0,green: 100/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        let color3 = UIColor(red: 247/255.0,green: 181/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        let color4 = UIColor(red: 109/255.0,green: 212/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        let color5 = UIColor(red: 0/255.0,green: 145/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        let color6 = UIColor(red: 98/255.0,green: 54/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        let color7 = UIColor(red: 182/255.0,green: 32/255.0, blue: 224/255.0, alpha: 1.0).cgColor
        
        headerLBL.gradientColors = [color1,color2,color3,color4,color5,color6,color7].reversed()
     
        
        
        super.awakeFromNib()
        // Initialization code
    }
    
    func check(isFollowing : Int){
        if isFollowing == 1{
            followBTN_Width.constant = followedBtn_width
        }else{
            followBTN_Width.constant = followBtn_width
        }
        
        followBTN.setBackgroundImage(isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
