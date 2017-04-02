//
//  STColorPickTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STColorPickTableViewCell: STLectureDetailTableViewCell {

    
    @IBOutlet weak var bgColorView: UIView!
    @IBOutlet weak var fgColorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var color : STColor! {
        didSet {
            bgColorView.backgroundColor = color.bgColor
            fgColorView.backgroundColor = color.fgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.addSubview(bgColorView)
        self.addSubview(fgColorView)
        color = STColor()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditable (_ editable: Bool) {
        if editable {
            self.accessoryType = .disclosureIndicator
        } else {
            self.accessoryType = .none
        }
    }
}
