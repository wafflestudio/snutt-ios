//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableTabViewController: UIViewController {
    
    var timetableViewController : STTimetableCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "settingChanged", event: STEvent.SettingChanged, object: nil)
    }
    
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        self.navigationItem.title = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableViewController?.reloadTimetable()
    }
    
    func settingChanged() {
        if STDefaults[.autoFit] {
            timetableViewController?.shouldAutofit = true
        } else {
            timetableViewController?.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableViewController?.columnHidden = columnHidden
            timetableViewController?.rowStart = Int(STDefaults[.timeRange][0])
            timetableViewController?.rowEnd = Int(STDefaults[.timeRange][1])
        }
        timetableViewController?.reloadTimetable()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STTimetableCollectionViewController") {
            timetableViewController = (segue.destinationViewController as! STTimetableCollectionViewController)
            timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
            settingChanged()
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
