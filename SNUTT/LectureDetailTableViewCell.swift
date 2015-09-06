//
//  LectureDetailTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 4..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class LectureDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
