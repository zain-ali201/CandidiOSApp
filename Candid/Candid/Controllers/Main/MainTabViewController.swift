//
//  MainTabViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit

class MainTabViewController: UITabBarController, TabbarViewDelegate {

    var tabbarView: TabbarView?
    override func viewDidLoad() {
        super.viewDidLoad()

        let backView = UIView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 50))
        backView.backgroundColor = .white
        self.tabBar.addSubview(backView)
        
        
        
        
        tabbarView = TabbarView.init(frame: CGRect.init(x: 0, y: self.tabBar.frame.height - 75, width: UIScreen.main.bounds.width, height:  75))
        tabbarView!.delegate = self
        self.tabBar.addSubview(tabbarView!)
        
        if #available(iOS 13.0, *){
            let appearance = tabBar.standardAppearance
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
        }else{
            let image = UIImage()
            tabBar.shadowImage = image
            tabBar.backgroundImage = image
            tabBar.backgroundColor = .white
        }
    }
    
    func tabBarItemClicked(index: Int) {
        self.selectedIndex = index
    }
    

}
