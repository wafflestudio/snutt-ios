//
//  STTimeTableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimeTableTabViewController: UIViewController {
    
    var timetableViewController : STTimeTableCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STTimeTableCollectionViewController") {
            timetableViewController = segue.destinationViewController as! STTimeTableCollectionViewController
            timetableViewController?.timetable = STTimetable(year: 2016, semester: "1")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
