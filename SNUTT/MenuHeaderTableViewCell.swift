//
//  MenuHeaderTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/06.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class MenuHeaderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func changeSemester(_ sender: UIButton, completion: () -> Void) {
        completion()
    }
    
    func setHeaderLabel(text: String) {
        headerLabel.text = text
    }
}
