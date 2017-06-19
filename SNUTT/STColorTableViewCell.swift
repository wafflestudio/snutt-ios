//
//  STColorTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STColorTableViewCell: UITableViewCell {

    @IBOutlet weak var fgColorView: UIView!
    @IBOutlet weak var bgColorView: UIView!
    @IBOutlet weak var colorContainerView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    var color : STColor! {
        didSet {
            fgColorView.backgroundColor = color.bgColor
            bgColorView.backgroundColor = color.fgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func setBorder(_ isBorder : Bool) {
        if isBorder {
            colorContainerView.layer.borderWidth = 1.0
            colorContainerView.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).cgColor
        } else {
            colorContainerView.layer.borderWidth = 0.0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

}
