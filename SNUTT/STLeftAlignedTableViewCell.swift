//
//  STLeftAlignedTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 20..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STLeftAlignedTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    internal static func loadWithOwner(owner : AnyObject!) -> STLeftAlignedTableViewCell {
        return NSBundle.mainBundle().loadNibNamed("STLeftAlignedTableViewCell", owner: owner, options: nil)[0] as! STLeftAlignedTableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(textField)
        self.selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
