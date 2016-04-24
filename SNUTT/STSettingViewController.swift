//
//  STSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSettingViewController: UITableViewController {

    @IBOutlet weak var versionCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        versionCell.detailTextLabel!.text = "최신 버전 사용중"
        STNetworking.checkLatestAppVersion { version in
            STDefaults[.appVersion] = version
            let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
            if (currentVersion < version) {
                self.versionCell.detailTextLabel!.text = "업데이트 가능"
            } else {
                self.versionCell.detailTextLabel!.text = "최신 버전 사용중"
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
