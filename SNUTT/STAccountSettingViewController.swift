//
//  STAccountSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STAccountSettingViewController: UITableViewController {
    
    enum CellType {
        case RightDetail(title: String, detail: String)
        case Button(title: String)
        case RedButton(title: String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section >= 2 {
            return 1
        }
        return 2
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = getCellType(indexPath)
        switch cellType {
        case .RightDetail(let title, let detail):
            let cell = tableView.dequeueReusableCellWithIdentifier("RightDetailCell", forIndexPath: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = detail
            return cell
        case .Button(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell", forIndexPath: indexPath)
            cell.textLabel?.text = title
            cell.accessoryType = .DisclosureIndicator
            return cell
        case .RedButton(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier("RedButtonCell",forIndexPath: indexPath) as! STRedButtonTableViewCell
            cell.buttonLabel.text = title
            return cell
        }
    }
    
    func getCellType(indexPath: NSIndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return .RightDetail(title: "아이디", detail: STUser.currentUser?.localId ?? "Empty")
        case (0,1):
            return .Button(title: STUser.currentUser?.localId != nil ? "비밀번호 변경" : "아이디 비번으로 회원가입")
        case (1,0):
            return .RightDetail(title: "페이스북 아이디", detail: STUser.currentUser?.fbId ?? "Empty")
        case (1,1):
            let title = STUser.currentUser?.fbId != nil ? "페이스북 연동 해제" : "페이스북 연동"
            return .Button(title: title)
        case (2,0):
            return .RedButton(title: "회원탈퇴")
        default:
            return .RightDetail(title: "", detail: "")
        }

    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0,1):
            //TODO : 비번 변경, 회원가입
            break
        case (1,1):
            //TODO: 페이스북 관련
            break
        case (2,0):
            //TODO: 회원탈퇴 alertview
            break
        default:
            break
        }
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
