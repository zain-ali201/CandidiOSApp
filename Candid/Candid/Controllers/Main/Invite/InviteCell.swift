//
//  InviteCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//


import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var imgView : UIImageViewX!
    @IBOutlet var inviteBTN : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        inviteBTN.layer.cornerRadius = 5
        inviteBTN.clipsToBounds = true
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        nameLabel.font = AppFont.SemiBold.size(15)
        nameLabel.textColor = UIColor(named: "MainBlack")
        inviteBTN.titleLabel?.font = AppFont.SemiBold.size(14)
        
//        let gradient = CAGradientLayer()
//        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.inviteBTN.frame.size)
//        gradient.colors = [UIColor(red: 247 / 255, green: 58 / 255, blue: 196 / 255, alpha: 1.0).cgColor, UIColor(red: 55 / 255, green: 158 / 255, blue: 246 / 255, alpha: 1.0).cgColor, UIColor(red: 245 / 255, green: 249 / 255, blue: 70 / 255, alpha: 1.0).cgColor, UIColor(red: 243 / 255, green: 78 / 255, blue: 78 / 255, alpha: 1.0).cgColor]
//
//        let shape = CAShapeLayer()
//        shape.lineWidth = 4
//        shape.cornerRadius = 5
//        shape.path = UIBezierPath(rect: self.inviteBTN.bounds).cgPath
//        shape.strokeColor = UIColor.black.cgColor
//        shape.fillColor = UIColor.clear.cgColor
//        gradient.mask = shape
//
//        self.inviteBTN.layer.insertSublayer(gradient, at: 0)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
