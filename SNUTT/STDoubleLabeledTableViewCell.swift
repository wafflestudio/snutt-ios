//
//  STDoubleLabeledTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STDoubleLabeledTableViewCell: UITableViewCell {

    @IBOutlet weak var firstTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var secondTextField: B68UIFloatLabelTextField!
    
    internal static func loadWithOwner(owner : AnyObject!) -> STDoubleLabeledTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STDoubleLabeledTableViewCell", owner: owner, options: nil)[0] as! STDoubleLabeledTableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(firstTextField)
        self.addSubview(secondTextField)
        self.selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
