//
//  TimetablePickerViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/07.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol TimetablePickerViewControllerDelegate: UIViewController {
    func chooseSemester(_ controller: TimetablePickerViewController)
}

class TimetablePickerViewController: UIViewController {
    
    weak var delegate: TimetablePickerViewControllerDelegate?

    @IBOutlet weak var semesterPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
