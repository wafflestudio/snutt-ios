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
    var timeDoneBlock : ((STTime)->())?
    var custom : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(timeTextField)
        self.addSubview(placeTextField)
        
        timeTextField.delegate = self
        placeTextField.delegate = self
        self.selectionStyle = .none
        // Initialization code
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == timeTextField {
            STTimeActionSheetPicker.showWithTime(singleClass.time,
                doneBlock: { time in
                    self.singleClass.time = time
                    self.timeTextField.text = self.singleClass.time.shortString()
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
        self.placeTextField.isEnabled = editable
        self.timeTextField.isEnabled = custom && editable
        if editable && !custom {
            self.timeTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
        } else {
            self.timeTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
        }
    }

}
