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
        for item in self.tabBar.items! {
            item.image = item.image!.imageWithRenderingMode(.AlwaysOriginal)
        }
        setNotiBadge(STDefaults[.shouldShowBadge])
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
    }
    
    func setNotiBadge(shouldShowBadge: Bool) {
        let notiBarItem = self.tabBar.items![2]
        if (shouldShowBadge) {
            notiBarItem.image = UIImage(named: "tabbaritem_noti_dot")!.imageWithRenderingMode(.AlwaysOriginal)
            notiBarItem.selectedImage = UIImage(named: "tabbaritem_noti_bold_dot")!.imageWithRenderingMode(.AlwaysOriginal)
        } else {
            notiBarItem.image = UIImage(named: "tabbaritem_noti")!.imageWithRenderingMode(.AlwaysOriginal)
            notiBarItem.selectedImage = UIImage(named: "tabbaritem_noti_bold")!.imageWithRenderingMode(.AlwaysOriginal)
        }
        STDefaults[.shouldShowBadge] = shouldShowBadge
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
