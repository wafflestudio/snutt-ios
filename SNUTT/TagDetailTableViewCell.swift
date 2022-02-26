//
//  TagDetailTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/20.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class TagDetailTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet var tagDetailLabel: UILabel!
    @IBOutlet var checkedImage: UIImageView!

    func setLabel(text: String) {
        tagDetailLabel.text = text
    }

    func check() {
        checkedImage.image = UIImage(named: "checkMint")
    }

    func unCheck() {
        checkedImage.image = UIImage(named: "unCheck")
    }
}
