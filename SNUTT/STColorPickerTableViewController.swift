//
//  STColorPickerTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STColorPickerTableViewController: UITableViewController {
    let customColorIndex = STColor.colorList.count
    var color : STColor!
    var selectedColorIndex = STColor.colorList.count
    var doneBlock : (STColor) -> () = { _ in }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<STColor.colorList.count {
            if STColor.colorList[i] == self.color {
                selectedColorIndex = i
                break
            }
        }
        
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedColorIndex, inSection: 0), animated: false, scrollPosition: .None)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            doneBlock(color)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedColorIndex == customColorIndex {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return STColor.colorList.count + 1
        case 1:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("STColorTableViewCell", forIndexPath: indexPath) as! STColorTableViewCell
            if indexPath.row == STColor.colorList.count {
                cell.color = STColor()
                cell.colorLabel.text = "Custom" //FIXME
            } else {
                cell.color = STColor.colorList[indexPath.row]
                cell.colorLabel.text = STColor.colorNameList[indexPath.row]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("STSingleColorTableViewCell", forIndexPath: indexPath) as! STSingleColorTableViewCell
            cell.accessoryType = .DisclosureIndicator
            if indexPath.row == 0 {
                cell.label.text = "Background Color" //FIXME
                cell.colorView.backgroundColor = color.bgColor
            } else {
                cell.label.text = "Foreground Color" //FIXME
                cell.colorView.backgroundColor = color.fgColor
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row != selectedColorIndex {
                self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: selectedColorIndex, inSection: 0), animated: true)
                
                let wasSelectedColorIndex = selectedColorIndex
                selectedColorIndex = indexPath.row
                
                if wasSelectedColorIndex == customColorIndex {
                    self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Top)
                }
                if selectedColorIndex != customColorIndex {
                    color = STColor.colorList[indexPath.row]
                } else {
                    color = STColor()
                    self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Top)
                }
            }
        } else if indexPath.section == 1 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let pickerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("STCustomColorPickerViewController") as! STCustomColorPickerViewController
            if indexPath.row == 0 {
                pickerViewController.color = self.color.bgColor
                pickerViewController.doneBlock = { color in
                    self.color.bgColor = color
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                }
            } else {
                pickerViewController.color = self.color.fgColor
                pickerViewController.doneBlock = { color in
                    self.color.fgColor = color
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                }
            }
            
            self.navigationController?.pushViewController(pickerViewController, animated: true)
        }
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
