//
//  STMainTabBarController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 9. 18..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STMainTabBarController: UITabBarController {
    
    static weak var controller : STMainTabBarController? = nil
    
    weak var notificationController : STNotificationTableViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STMainTabBarController.controller = self
        for item in self.tabBar.items! {
            item.image = item.image!.withRenderingMode(.alwaysOriginal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let reviewTabIndex = 2
        
        if self.selectedIndex == reviewTabIndex {
            if let navVC = self.viewControllers?[self.selectedIndex] as? UINavigationController, let reviewVC = navVC.viewControllers.first as? ReviewViewController {
                reviewVC.loadMainView()
            }
        }
    }
}
