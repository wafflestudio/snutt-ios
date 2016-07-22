//
//  STLectureTimeAddButtonCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 5. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSingleLectureButtonCell: STLectureDetailTableViewCell {
    
    
    @IBOutlet weak var button: UIButton!
    
    var buttonAction : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonClicked(sender: AnyObject) {
        buttonAction?();
    }
}
