//
//  STSingleClassTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STSingleClassTableViewCell: STLectureDetailTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var timeTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var placeTextField: B68UIFloatLabelTextField!
    
    var singleClass : STSingleClass! {
        didSet {
            timeTextField.text = singleClass.time.shortString()
            placeTextField.text = singleClass.place
        }
    }
    var placeDoneBlock : ((String)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(timeTextField)
        self.addSubview(placeTextField)
        
        timeTextField.delegate = self
        placeTextField.delegate = self
        self.selectionStyle = .None
        // Initialization code
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == timeTextField {
            STTimeActionSheetPicker.showWithTime(singleClass.time,
                doneBlock: { time in
                    self.singleClass.time = time
                    self.timeTextField.text = self.singleClass.time.shortString()
                }, cancelBlock: nil, origin: textField)
            return false
        } else if textField == placeTextField {
            return true
        }
        return false // Never Reachable
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == placeTextField {
            placeDoneBlock?(textField.text!)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditable(editable: Bool) {
        self.placeTextField.enabled = editable
        if editable {
            self.timeTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
        } else {
            self.timeTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
        }
    }

}
