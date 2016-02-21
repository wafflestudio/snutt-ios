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

    @IBOutlet weak var colorView: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var lightColor : UIColor! {
        didSet {
            colorView.backgroundColor = lightColor
        }
    }
    var darkColor : UIColor! {
        didSet {
            colorView.layer.borderColor = darkColor.CGColor
            colorView.layer.borderWidth = 5.0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
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
