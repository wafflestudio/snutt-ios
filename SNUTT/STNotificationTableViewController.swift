//
//  STNotificationTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire

class STNotificationTableViewController: UITableViewController {
    let heightForFetch : CGFloat = CGFloat(50.0)
    
    var sizingCell : STNotificationTableViewCell!
    
    var notiList : [STNotification] = []
    var pageCnt : Int = 0
    var numPerPage : Int = 10
    
    var loading : Bool = false
    var isLast : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "STNotificationTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "STNotificationTableViewCell")
        sizingCell = nib.instantiateWithOwner(self, options: nil)[0] as! STNotificationTableViewCell
        
        refreshList()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshList), forControlEvents: UIControlEvents.ValueChanged)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notiList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STNotificationTableViewCell", forIndexPath: indexPath) as! STNotificationTableViewCell
        let notification = notiList[indexPath.row]
        cell.notification = notification

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        sizingCell.notification = notiList[indexPath.row]
        return sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch {
            if !loading && !isLast {
                getMoreList()
            }
        }
    }
    
    func getMoreList() {
        loading = true
        STNetworking.getNotificationList(numPerPage, offset: numPerPage * pageCnt, explicit: true, done: { list in
            self.loading = false
            self.notiList = self.notiList + list
            self.pageCnt += 1
            
            if list.count < self.numPerPage {
                self.isLast = true
            }
            self.tableView.reloadData()
        }, failure: {
            // There is no error other than networking error
            self.loading = false
        })
    }
    
    func refreshList() {
        loading = true
        pageCnt = 0
        isLast = false
        STNetworking.getNotificationList(numPerPage, offset: numPerPage * pageCnt, explicit: true, done: { list in
            self.loading = false
            self.notiList = list
            if list.count < self.numPerPage {
                self.isLast = true
            }
            self.pageCnt += 1
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            formatter.timeStyle = NSDateFormatterStyle.MediumStyle
            
            let title = "Last update: \(formatter.stringFromDate(NSDate()))"
            self.refreshControl?.attributedTitle = NSAttributedString(string: title)
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }, failure: {
                // There is no error other than networking error
                self.loading = false
        })
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
