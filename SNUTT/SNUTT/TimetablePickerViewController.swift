//
//  TimetablePickerViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/07.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol TimetablePickerViewControllerDelegate: UIViewController {
    func changeSemester(_ controller: TimetablePickerViewController, index: Int)
}

class TimetablePickerViewController: UIViewController {
    weak var delegate: TimetablePickerViewControllerDelegate?

    var semesterList: [STQuarter] = []
    var selectedSemesterIndex = 0

    @IBOutlet weak var semesterPickerView: UIPickerView!

    @IBAction func selectSemester(_: UIButton) {
        delegate?.changeSemester(self, index: selectedSemesterIndex)

        dismiss(animated: true)
    }

    @IBAction func cancel(_: UIButton) {
        dismiss(animated: true)
    }

    var semesterListInString: [String] {
        return semesterList.map { semseter in
            semseter.longString()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        semesterPickerView.delegate = self
        semesterPickerView.dataSource = self

        semesterPickerView.selectRow(selectedSemesterIndex, inComponent: 0, animated: true)
    }

    func setSemesterList(list: [STQuarter]) {
        semesterList = list
    }

    func setSelectedSemester(index: Int?) {
        selectedSemesterIndex = index ?? 0
    }
}

extension TimetablePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return semesterList.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return semesterListInString[row]
    }

    func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
        return 32
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedSemesterIndex = row
    }
}
