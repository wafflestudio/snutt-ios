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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STMainTabBarController.controller = self
        self.tabBar.tintColor = UIColor.blackColor()
        for item in self.tabBar.items! {
            item.image = item.image!.imageWithRenderingMode(.AlwaysOriginal)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
    }
    
    func setNotiBadge(count: Int) {
        let notiBarItem = self.tabBar.items![3]
        //TODO: noti bar item badge
        if (count > 0) {
            notiBarItem.badgeValue = "" // FIXME: show badge by icon img
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        } else {
            notiBarItem.badgeValue = nil // FIMXE: show badge by icon img
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
