//
//  AddLectureViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 7..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class AddLectureViewController: UIViewController {
    
    var searchController : LectureSearchTableViewController = LectureSearchTableViewController()
    
    @IBOutlet weak var searchTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTable.delegate = searchController
        searchTable.dataSource = searchController
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
