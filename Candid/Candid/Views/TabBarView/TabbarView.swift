//
//  TabbarView.swift
//  Stesso
//
//  Created by Stesso on 2020/3/29.
//  Copyright © 2020 Stesso. All rights reserved.
//

import Foundation
import UIKit

public protocol TabbarViewDelegate: NSObjectProtocol {
    func tabBarItemClicked(index: Int)
}

class TabbarView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    var delegate: TabbarViewDelegate?

    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var findImageView: UIImageView!
    @IBOutlet weak var notificationsImageView: UIImageView!
    @IBOutlet weak var notificationsBTN: UIButton!

    
    var currentSelectedIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    private func viewInit() {
        Bundle.main.loadNibNamed("TabbarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        profileImageView.isHidden = true
        findImageView.isHidden = true
        notificationsImageView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeClicked), name: NSNotification.Name("closeButtonClicked"), object: nil)
        
        
      checkNotificationCounter()
    }
    func checkNotificationCounter(){
        if (UIApplication.shared.applicationIconBadgeNumber > 0){
            self.notificationsBTN.setImage(UIImage(named: "notificationS"), for: .normal)
        }else{
            self.notificationsBTN.setImage(UIImage(named: "notification"), for: .normal)
        }
    }
    @objc func closeClicked(){
        selectTab(index: 0)
    }
    
    @IBAction func homeButtonClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("GoTop"), object: nil)
        selectTab(index: 0)
    }
    
    @IBAction func findButtonClicked(_ sender: UIButton) {
        selectTab(index: 1)
    }
    
    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        selectTab(index: 2)
    }
    
    @IBAction func notificationButtonClicked(_ sender: UIButton) {
        checkNotificationCounter()
        selectTab(index: 3)
    }
    
    @IBAction func profileButtonClicked(_ sender: UIButton) {
        selectTab(index: 4)
    }
    
    
    
    public func selectTab(index: Int) {
        if currentSelectedIndex == index {
            return
        } else {
            currentSelectedIndex = index
            delegate?.tabBarItemClicked(index: index)
            
            homeImageView.isHidden = index == 0 ? false : true
            
            findImageView.isHidden = index == 1 ? false : true
            
            notificationsImageView.isHidden = index == 3 ? false : true
            
            profileImageView.isHidden = index == 4 ? false : true
        }
    }
    
}
