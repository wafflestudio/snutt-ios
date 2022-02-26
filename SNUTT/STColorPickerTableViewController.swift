//
//  STColorPickerTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import ChameleonFramework
import UIKit

class STColorPickerTableViewController: UITableViewController {
    var customColorIndex = 9
    var color: STColor!
    var colorIndex: Int = 1
    var selectedColorIndex = 1
    var doneBlock: (Int, STColor?) -> Void = { _, _ in }
    var theme: STTheme?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "STColorTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "STColorTableViewCell")
        tableView.register(UINib(nibName: "STSingleColorTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "STSingleColorTableViewCell")

        colorListUpdated()

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(colorListUpdated), event: STEvent.ColorListUpdated, object: nil)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            let retColorIndex = selectedColorIndex == customColorIndex ? 0 : selectedColorIndex + 1
            let retColor = selectedColorIndex == customColorIndex ? color : nil
            doneBlock(retColorIndex, retColor)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func colorListUpdated() {
        selectedColorIndex = colorIndex
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: selectedColorIndex, section: 0), animated: false, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        if selectedColorIndex == customColorIndex {
            return 2
        } else {
            return 1
        }
    }

    var colorList: [String] {
        return theme?.getColorList() ?? []
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return colorList.count
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "STColorTableViewCell", for: indexPath) as! STColorTableViewCell
            if indexPath.row == colorList.count - 1 {
                cell.color = STColor()
                cell.colorLabel.text = "직접 지정하기"
                cell.setBorder(false)
            } else {
                if let theme = theme {
                    let fgColor = "#ffffff"
                    cell.color = STColor(fgHex: fgColor, bgHex: colorList[indexPath.row + 1])
                    cell.colorLabel.text = "\(theme.getName()) \(indexPath.row + 1)"
                    cell.setBorder(true)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "STSingleColorTableViewCell", for: indexPath) as! STSingleColorTableViewCell
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0 {
                cell.label.text = "배경색"
                cell.colorView.backgroundColor = color.bgColor
            } else {
                cell.label.text = "글씨색"
                cell.colorView.backgroundColor = color.fgColor
            }
            return cell
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row != selectedColorIndex {
                tableView.deselectRow(at: IndexPath(row: selectedColorIndex, section: 0), animated: true)

                let wasSelectedColorIndex = selectedColorIndex
                selectedColorIndex = indexPath.row

                if wasSelectedColorIndex == customColorIndex {
                    tableView.deleteSections(IndexSet(integer: 1), with: .top)
                }
                if selectedColorIndex != customColorIndex {
                    let bg = colorList[indexPath.row]
                    color = STColor(fgHex: "ffffff", bgHex: bg)
                } else {
                    color = STColor()
                    tableView.insertSections(IndexSet(integer: 1), with: .top)
                }
            }
        } else if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let pickerViewController = storyboard?.instantiateViewController(withIdentifier: "STCustomColorPickerViewController") as! STCustomColorPickerViewController
            if indexPath.row == 0 {
                pickerViewController.color = color.bgColor
                pickerViewController.doneBlock = { color in
                    self.color.bgColor = color
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            } else {
                pickerViewController.color = color.fgColor
                pickerViewController.doneBlock = { color in
                    self.color.fgColor = color
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            }

            navigationController?.pushViewController(pickerViewController, animated: true)
        }
    }

    override func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
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
