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
        STTimetableManager.sharedInstance.currentTimetable = STTimetable(year: 2016, semester: 0, title: "testing")
        self.navigationController!.title = STTimetableManager.sharedInstance.currentTimetable?.title
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableViewController?.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STTimetableCollectionViewController") {
            timetableViewController = (segue.destinationViewController as! STTimetableCollectionViewController)
            timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
