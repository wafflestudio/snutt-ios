//
//  TagTypeTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/20.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class TagTypeTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var tagLabel: UILabel!

    func setLabel(text: String) {
        tagLabel.text = text
    }

    func checkLabel() {
        tagLabel.textColor = .black
    }

    func unCheckLabel() {
        tagLabel.textColor = .lightGray
    }
}
