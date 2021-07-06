//
//  MenuTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/05.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var timetableLabel: UILabel!
    @IBOutlet weak var checkedIcon: UIImageView!
    
    @IBAction func duplicateButton(_ sender: UIButton) {
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
    }
    
    func checkCurrentTimetable() {
        checkedIcon.image = UIImage(systemName: "circle.fill")
        checkedIcon.tintColor = .red
    }
    
    func setLabel(text: String) {
        timetableLabel.text = text
    }
}
