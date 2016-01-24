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
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var academicYearLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    
    var lecture : STLecture? {
        didSet {
            titleLabel.text = lecture?.title
            creditLabel.text = "\(lecture?.credit)학점"
            instructorLabel.text = lecture?.instructor
            classificationLabel.text = lecture?.classification
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
