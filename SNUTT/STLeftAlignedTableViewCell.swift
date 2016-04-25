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
        self.selectionStyle = .None
        textField.delegate = self
        // Initialization code
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        doneBlock?(textField.text!)
    }
    
    override func setEditable (editable: Bool) {
        textField.enabled = editable
    }
    

}
