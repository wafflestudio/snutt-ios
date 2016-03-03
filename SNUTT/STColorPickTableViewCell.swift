//
//  STColorPickTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STColorPickTableViewCell: UITableViewCell {

    
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
        self.accessoryType = .DisclosureIndicator
        self.selectionStyle = .Gray
        self.addSubview(bgColorView)
        self.addSubview(fgColorView)
        color = STColor.colorList[0]
        // Initialization code
    }
    
    internal static func loadWithOwner(owner : AnyObject!) -> STColorPickTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STColorPickTableViewCell", owner: owner, options: nil)[0] as! STColorPickTableViewCell
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
