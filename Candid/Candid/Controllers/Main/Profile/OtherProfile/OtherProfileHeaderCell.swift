//
//  OtherProfileHeaderCell.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//


import UIKit


protocol OtherProfileHeaderDelegate: AnyObject {
    func followTapped()
}
class OtherProfileHeaderCell: UITableViewCell {
    weak var delegate: OtherProfileHeaderDelegate?
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        backButton.imageEdgeInsets = UIEdgeInsets(top: 10,left: 5,bottom: 10,right: 5)
        followButton.onTap {
            self.delegate?.followTapped()
        }
        // Initialization code
    }
   
    
    func setData(forUser : User){
        self.fullnameLabel.text = forUser.fullname
        self.usernameLabel.text = forUser.username
        self.bioLabel.text = forUser.bio
        self.profileImageView.load(photoUrl: "\(image_URL)\(forUser.profile_image_url)", placeHolder: "avatar")
//        self.profileImageView.sd_setImage(with: URL(string: "\(image_URL)\(forUser.profile_image_url)"), placeholderImage: UIImage(named: "avatar"))
        self.followButton.setBackgroundImage(forUser.isFollowing == 0 ? UIImage(named: "follow_button") : UIImage(named: "followed_button"), for: .normal)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
