//
//  STLectureTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!

    var lecture: STLecture! {
        didSet {
            titleLabel.text = lecture.title == "" ? "강좌명" : lecture.title
            titleLabel.textColor = lecture.title == "" ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.0, alpha: 1.0)
            descriptionLabel.text = "\(lecture.instructor) / \(lecture.credit)학점"
            tagLabel.text = lecture.tagDescription
            timeLabel.text = lecture.timeDescription
            placeLabel.text = lecture.placeDescription
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
