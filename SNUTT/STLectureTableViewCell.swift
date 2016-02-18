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
    
    var lecture : STLecture! {
        didSet {
            titleLabel.text = lecture.title
            descriptionLabel.text = "(\(lecture.instructor) / \(lecture.credit)학점)"
            var tagText = ""
            if lecture.category != "" {
                tagText = tagText + lecture.category + ", "
            }
            if lecture.department != "" {
                tagText = tagText + lecture.department + ", "
            }
            if lecture.academicYear != "" {
                tagText = tagText + lecture.academicYear + ", "
            }
            tagLabel.text = tagText
            //TODO: timeLabel.text = lecture.??
            //placeLabel.text =
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
