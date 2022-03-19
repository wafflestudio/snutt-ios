//
//  STLeftAlignedLabelCell.swift
//  SNUTT
//
//  Created by Rajin on 2017. 7. 23..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STLeftAlignedLabelCell: STLectureDetailTableViewCell {
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
