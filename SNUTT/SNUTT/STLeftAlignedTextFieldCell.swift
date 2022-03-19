//
//  STLeftAlignedTextFieldCell.swift
//  SNUTT
//
//  Created by Rajin on 2017. 7. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STLeftAlignedTextFieldCell: STLectureDetailTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var doneBlock: ((String)->())?
    var isEditableField : Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        doneBlock?(textField.text!)
    }
    
    override func setEditable (_ editable: Bool) {
        textField.isEnabled = editable && isEditableField
        textField.textColor = editable && !isEditableField ? UIColor(white: 0.8, alpha: 1.0) : UIColor(white: 0.0, alpha: 1.0)
    }
    
}
