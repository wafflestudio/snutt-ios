//
//  STSingleClassTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
class STSingleClassTableViewCell: UITableViewCell {

    @IBOutlet weak var timeTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var placeTextField: B68UIFloatLabelTextField!
    
    var singleClass : STSingleClass! {
        didSet {
            timeTextField.text = singleClass.startTime.toShortString()
            placeTextField.text = singleClass.place
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal static func loadWithOwner(owner : AnyObject!) -> STSingleClassTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STSingleClassTableViewCell", owner: owner, options: nil)[0] as! STSingleClassTableViewCell
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
