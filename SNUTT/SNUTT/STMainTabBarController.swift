//
//  STMainTabBarController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 9. 18..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STMainTabBarController: UITabBarController {
    weak static var controller: STMainTabBarController?

    weak var notificationController: STNotificationTableViewController?

    private var reviewTabBarItem: UITabBarItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        STMainTabBarController.controller = self
        for item in tabBar.items! {
            item.image = item.image!.withRenderingMode(.alwaysOriginal)
        }

        reviewTabBarItem = tabBar.items![2]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
        if item == reviewTabBarItem {
            if let navVC = viewControllers?[selectedIndex] as? UINavigationController, let reviewVC = navVC.viewControllers.first as? ReviewViewController {
                reviewVC.loadMainView()
            }
        }
    }
}
