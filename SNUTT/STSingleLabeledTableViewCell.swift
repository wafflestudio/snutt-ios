//
//  STSingleLabeledTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STSingleLabeledTableViewCell: STLectureDetailTableViewCell {

    @IBOutlet weak var valueTextField: B68UIFloatLabelTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(valueTextField)
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditable (_ editable: Bool) {
        if editable {
            self.valueTextField.textColor = UIColor(white: 0.67, alpha: 1.0)
        } else {
            self.valueTextField.textColor = UIColor(white: 0.0, alpha: 1.0)
        }
    }

}
