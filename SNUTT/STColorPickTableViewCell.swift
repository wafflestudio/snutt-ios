//
//  STColorPickTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import ChameleonFramework
import UIKit

class STColorPickTableViewCell: STLectureDetailTableViewCell {
    @IBOutlet var bgColorView: UIView!
    @IBOutlet var fgColorView: UIView!
    @IBOutlet var colorContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var arrowImage: UIImageView!

    var color: STColor! {
        didSet {
            bgColorView.backgroundColor = color.bgColor
            fgColorView.backgroundColor = color.fgColor
            setBorder(true)
        }
    }

    func setBorder(_ isBorder: Bool) {
        if isBorder {
            colorContainerView.layer.borderWidth = 1.0
            colorContainerView.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05).cgColor
        } else {
            colorContainerView.layer.borderWidth = 0.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .none
        selectionStyle = .none
        color = STColor()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setEditable(_ editable: Bool) {
        arrowImage.isHidden = !editable
    }
}
