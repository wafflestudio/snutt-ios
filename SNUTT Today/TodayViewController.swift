//
//  TodayViewController.swift
//  SNUTT Today
//
//  Created by Rajin on 2017. 3. 8..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON
import SwiftyUserDefaults

class TodayViewController: UIViewController, NCWidgetProviding {
    //TODO: iOS 9 Testing
    
    @IBOutlet weak var timetableView: STTimetableCollectionView!
    var maxHeight : CGFloat =  400.0

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    let sharedDefaults = UserDefaults(suiteName: "group.wafflestudio.TodayExtensionSharingDefaults")

    override func viewDidLoad() {
        // For STColorList UserDefaults
        NSKeyedArchiver.setClassName("STColorList", for: STColorList.self)
        NSKeyedUnarchiver.setClass(STColorList.self, forClassName: "STColorList")

        super.viewDidLoad()
        guard let extensionContext = self.extensionContext else {
            return
        }
        descriptionLabel.text = "SNUTT 시간표를 보기 위해서는 위의 더보기를 눌러주세요."

        updateTimetable()
        updateSetting()

        extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        let displayMode = extensionContext.widgetActiveDisplayMode
        let maxSize = extensionContext.widgetMaximumSize(for: displayMode)
        self.widgetActiveDisplayModeDidChange(displayMode, withMaximumSize: maxSize)

        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc func userDefaultsDidChange (_ notification: Notification) {
        updateTimetable()
        updateSetting()
    }

    func updateTimetable() {
        if let dict = STDefaults[.currentTimetable] {
            let timetable = STTimetable(json: JSON(dict))
            timetableView.reloadTimetable(timetable)
        } else {
            timetableView.timetable = nil
        }
    }

    func reloadData() {
        timetableView.reloadData()
    }

    func updateSetting() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableView.columnHidden = columnHidden
            timetableView.rowStart = Int(STDefaults[.timeRange][0])
            timetableView.rowEnd = Int(STDefaults[.timeRange][1])
        }
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
            timetableView.frame.size = maxSize
            reloadData()
            timetableView.isHidden = true
            descriptionLabel.isHidden = false
        }
        else {
            self.preferredContentSize = CGSize(width: 0, height: maxHeight)
            timetableView.frame.size = CGSize(width: 0, height: maxHeight)
            reloadData()
            timetableView.isHidden = false
            descriptionLabel.isHidden = true
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        DispatchQueue.main.async(execute: {
            self.updateTimetable()
            self.updateSetting()
            self.reloadData()
        });

        completionHandler(NCUpdateResult.newData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
