//
//  STNotificationTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var notification : STNotification! {
        didSet {
            
            let grayAttribute = [NSForegroundColorAttributeName: UIColor.grayColor()]
            let timeText = NSAttributedString(string: notification.createdFrom, attributes: grayAttribute)
            var message = NSMutableAttributedString(string: notification.message+" ")
            message.appendAttributedString(timeText)
            descriptionLabel.attributedText = message
            iconImageView.image = UIImage(named: notification.imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.lineBreakMode = .ByWordWrapping
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
