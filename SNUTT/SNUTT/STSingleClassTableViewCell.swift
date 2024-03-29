//
//  STSingleClassTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import B68UIFloatLabelTextField
import UIKit

class STSingleClassTableViewCell: STLectureDetailTableViewCell, UITextFieldDelegate {
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var deleteBtn: STViewButton!
    var customLecture: Bool = false
    var singleClass: STSingleClass! {
        didSet {
            timeTextField.text = singleClass.time.shortString(precise: !customLecture) // customLecture가 아닐때만 하드코딩된 값을 빼주도록 한다.
            placeTextField.text = singleClass.place
        }
    }

    var placeDoneBlock: ((String) -> Void)?
    var timeDoneBlock: ((STTime) -> Void)?
    var deleteLectureBlock: (() -> Void)? {
        didSet {
            deleteBtn.buttonPressAction = deleteLectureBlock
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        timeTextField.delegate = self
        placeTextField.delegate = self
        deleteBtn.buttonPressAction = deleteLectureBlock

        selectionStyle = .none
        // Initialization code
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == timeTextField {
            STTimeActionSheetPicker.showWithTime(singleClass.time,
                                                 doneBlock: { [weak self] time in
                                                     guard let self = self else { return }
                                                     self.singleClass.time = time
                                                     self.timeTextField.text = self.singleClass.time.shortString(precise: !self.customLecture)
                                                     self.timeDoneBlock?(time)
                                                 }, cancelBlock: nil, origin: textField)
            return false
        } else if textField == placeTextField {
            return true
        }
        return false // Never Reachable
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == placeTextField {
            placeDoneBlock?(textField.text!)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setEditable(_ editable: Bool) {
        placeTextField.isEnabled = editable
        timeTextField.isEnabled = customLecture && editable
        deleteBtn.isHidden = !(customLecture && editable)
        if editable, !customLecture {
            timeTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
        } else {
            timeTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
        }
    }
}
