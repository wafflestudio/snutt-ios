//
//  STLectureSearchTableViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureSearchTableViewCell: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    var lecture : STLecture? {
        didSet {
            titleLabel.text = "\(lecture!.name) (\(lecture!.professor)/\(lecture!.credit)학점)"
            label1.text = lecture?.classification
            label2.text = lecture?.department
            var timeString : String = ""
            for it in lecture!.classList {
                timeString = timeString + it.startTime.toShortString()
            }
            label3.text = timeString
        }
    }
    @IBAction func buttonClicked(sender: AnyObject) {
        
        var alertView = UIAlertView(title: "SNUTT", message: "", delegate: nil, cancelButtonTitle: "OK")
        switch STCourseBooksManager.sharedInstance.currentCourseBook!.addLecture(lecture!) {
        case .ErrorTime:
            alertView.message = "Time is Overlapping"
        case .ErrorSameLecture:
            alertView.message = "This Lecture is already added"
        case .Success:
            alertView.message = "Lecture is added to the timetable"
        }
        alertView.show()
        
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
