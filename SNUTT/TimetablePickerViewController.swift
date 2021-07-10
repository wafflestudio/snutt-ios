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
    
    var semesterList: [String] = []

    @IBOutlet weak var semesterPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        semesterPickerView.delegate = self
        semesterPickerView.dataSource = self
    }
    
    func setSemesterList(list: [String]) {
        semesterList = list
    }
}

extension TimetablePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return semesterList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return semesterList[row]
    }
}
