//
//  STDoubleLabeledTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STDoubleLabeledTableViewCell: STLectureDetailTableViewCell {

    @IBOutlet weak var firstTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var secondTextField: B68UIFloatLabelTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(firstTextField)
        self.addSubview(secondTextField)
        self.selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditable(editable : Bool) {
        if editable {
            self.firstTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
            self.secondTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
        } else {
            self.firstTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
            self.secondTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
        }
    }

}
