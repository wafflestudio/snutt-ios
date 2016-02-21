//
//  STTimetableAddController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableAddController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var semesterPicker: UIPickerView!
    
    weak var timetableListController : STTimetableListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        semesterPicker.delegate = self
        semesterPicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func canceclButtonClicked(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        let index = semesterPicker.selectedRowInComponent(0)
        let selectedCourseBook = STCourseBookList.sharedInstance.courseBookList![index]
        let title = titleTextField.text
        if (title == nil || title == "") {
            return //TODO: Alert the user for the missing title
        }
        self.view.endEditing(true)
        timetableListController.addTimetable(title!, courseBook: selectedCourseBook)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return STCourseBookList.sharedInstance.courseBookList!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return STCourseBookList.sharedInstance.courseBookList![row].quarter.longString()
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
