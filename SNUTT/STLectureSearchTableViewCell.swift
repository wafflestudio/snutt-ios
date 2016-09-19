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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    weak var tableView : UITableView!
    
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
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        tableView.deselectRowAtIndexPath(tableView.indexPathForCell(self)!, animated: true)
        lecture.color = STColor.colorList[0]
        STTimetableManager.sharedInstance.addLecture(lecture, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = .None
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            addButton.hidden = false
        } else {
            self.backgroundColor = UIColor.clearColor()
            addButton.hidden = true
        }
        
        // Configure the view for the selected state
    }


}
