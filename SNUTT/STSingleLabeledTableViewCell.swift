//
//  STSingleLabeledTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STSingleLabeledTableViewCell: UITableViewCell {

    @IBOutlet weak var valueTextField: B68UIFloatLabelTextField!
    
    internal static func loadWithOwner(owner : AnyObject!) -> STSingleLabeledTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STSingleLabeledTableViewCell", owner: owner, options: nil)[0] as! STSingleLabeledTableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(valueTextField)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
