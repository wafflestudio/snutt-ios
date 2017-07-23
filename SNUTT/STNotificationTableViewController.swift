//
//  STNotificationTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet

class STNotificationTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    let heightForFetch : CGFloat = CGFloat(50.0)

    var notiList : [STNotification] = []
    var pageCnt : Int = 0
    var numPerPage : Int = 15
    
    var loading : Bool = false
    var isLast : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 27
        
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        let nib = UINib(nibName: "STNotificationTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "STNotificationTableViewCell")
        
        refreshList()
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshList), for: UIControlEvents.valueChanged)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loading && STDefaults[.shouldShowBadge] {
            self.refreshControl?.beginRefreshing()
            self.refreshList()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height), animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notiList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STNotificationTableViewCell", for: indexPath) as! STNotificationTableViewCell
        let notification = notiList[indexPath.row]
        cell.notification = notification

        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        STMainTabBarController.controller?.setNotiBadge(false)
        STNetworking.getNotificationList(numPerPage, offset: numPerPage * pageCnt, explicit: true, done: { list in
            self.loading = false
            self.notiList = list
            STMainTabBarController.controller?.setNotiBadge(false)
            if list.count < self.numPerPage {
                self.isLast = true
            }
            self.pageCnt += 1
            
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            formatter.timeStyle = DateFormatter.Style.medium
            
            let title = "Last update: \(formatter.string(from: Date()))"
            self.refreshControl?.attributedTitle = NSAttributedString(string: title)
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }, failure: {
                // There is no error other than networking error
                self.loading = false
        })
    }
    
    //MARK: DNZEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "tabAlarmOn")
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(white: 0.8, alpha: 1.0)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "알림이 없습니다."
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18.0)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "넣은 강좌의 수강편람이 바뀌거나, 새로운 수강편람이 뜨면 알림을 줍니다.".breakOnlyAtNewLineAndSpace
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 14.0),
            NSForegroundColorAttributeName : UIColor.lightGray,
            NSParagraphStyleAttributeName : paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
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
