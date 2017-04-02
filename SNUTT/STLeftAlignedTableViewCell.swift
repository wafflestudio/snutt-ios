//
//  STLeftAlignedTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STLeftAlignedTableViewCell: STLectureDetailTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var doneBlock : ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(textField)
        self.selectionStyle = .none
        textField.delegate = self
        // http://stackoverflow.com/questions/39556087/uitextfield-chinese-character-moves-down-when-editing-in-ios-10
        // Some stupid bug
        textField.borderStyle = .none
        // Initialization code
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        doneBlock?(textField.text!)
    }
    
    override func setEditable (_ editable: Bool) {
        textField.isEnabled = editable
    }
    

}
