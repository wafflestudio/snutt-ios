//
//  STSingleClassTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STSingleClassTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var timeTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var placeTextField: B68UIFloatLabelTextField!
    
    var singleClass : STSingleClass! {
        didSet {
            timeTextField.text = singleClass.time.shortString()
            placeTextField.text = singleClass.place
        }
    }
    
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
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == placeTextField {
            singleClass.place = placeTextField.text!
        }
    }
    
    internal static func loadWithOwner(owner : AnyObject!) -> STSingleClassTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STSingleClassTableViewCell", owner: owner, options: nil)[0] as! STSingleClassTableViewCell
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
