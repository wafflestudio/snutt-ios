//
//  STMyLectureListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import DZNEmptyDataSet
import UIKit

class STMyLectureListController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    weak var timetableTabViewController: STTimetableTabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.register(UINib(nibName: "STLectureTableViewCell", bundle: nil), forCellReuseIdentifier: "LectureCell")
        tableView.register(UINib(nibName: "STAddLectureButtonCell", bundle: nil), forCellReuseIdentifier: "AddButtonCell")
        tableView.rowHeight = 74.0

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(reloadData(_:)), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(reloadData(_:)), event: STEvent.CurrentTimetableSwitched, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func reloadData(_ notification: Notification) {
        if (notification.object as AnyObject) === self {
            return // This is because of delete animation.
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let cnt = STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return cnt == 0 ? 0 : cnt + 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as! STAddLectureButtonCell
            cell.titleLabel.text = "직접 강좌 추가하기"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LectureCell", for: indexPath) as! STLectureTableViewCell
            cell.lecture = STTimetableManager.sharedInstance.currentTimetable?.lectureList[indexPath.row]
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView.numberOfRows(inSection: 0) != 2 {
                STTimetableManager.sharedInstance.deleteLectureAtIndex(indexPath.row, object: self)
            } else {
                STTimetableManager.sharedInstance.deleteLectureAtIndex(indexPath.row, object: self)
            }
            self.tableView.reloadEmptyDataSet()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            performSegue(withIdentifier: "AddCustomLecture", sender: self)
        } else {
            let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
            detailController.lecture = STTimetableManager.sharedInstance.currentTimetable?.lectureList[indexPath.row]
            detailController.theme = STTimetableManager.sharedInstance.currentTimetable?.theme
            navigationController?.pushViewController(detailController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == STTimetableManager.sharedInstance.currentTimetable?.lectureList.count {
            return 40.0
        }
        return 106.0
    }

    // MARK: DNZEmptyDataSet

    func image(forEmptyDataSet _: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "tabTimetableOn")
    }

    func imageTintColor(forEmptyDataSet _: UIScrollView!) -> UIColor! {
        return UIColor(white: 0.8, alpha: 1.0)
    }

    func title(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
        let text = "시간표에 강좌가 없습니다."
        let attributes: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.boldSystemFont(ofSize: 18.0),
        ]
        return NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }

    func description(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
        let text = "강좌를 찾아서 넣을수도 있지만, 직접 만들수도 있습니다.".breakOnlyAtNewLineAndSpace
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 14.0),
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.lightGray,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraph,
        ]
        return NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }

    func buttonTitle(forEmptyDataSet _: UIScrollView!, for _: UIControl.State) -> NSAttributedString! {
        let text = "직접 만들기"
        let attributes: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.boldSystemFont(ofSize: 17.0),
        ]
        return NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }

    func emptyDataSetDidTapButton(_: UIScrollView!) {
        performSegue(withIdentifier: "AddCustomLecture", sender: self)
    }

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
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
