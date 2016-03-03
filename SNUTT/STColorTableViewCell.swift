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
    @IBOutlet weak var colorLabel: UILabel!
    
    var color : STColor! {
        didSet {
            fgColorView.backgroundColor = color.bgColor
            bgColorView.backgroundColor = color.fgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
        }
    }

}
