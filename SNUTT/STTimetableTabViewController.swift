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
        self.navigationItem.title = STTimetableManager.sharedInstance.currentTimetable!.title
        
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableSwitched, object: nil)
    }
    
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        self.navigationItem.title = STTimetableManager.sharedInstance.currentTimetable!.title
        timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableViewController?.reloadTimetable()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STTimetableCollectionViewController") {
            timetableViewController = (segue.destinationViewController as! STTimetableCollectionViewController)
            timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
            timetableViewController?.shouldAutofit = true
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
