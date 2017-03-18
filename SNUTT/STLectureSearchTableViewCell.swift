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
    
    var lecture : STLecture? {
        didSet {
            titleLabel.text = lecture?.title
            descriptionLabel.text = "(\(lecture!.instructor) / \(lecture!.credit)학점)"
            if self.selected {
                tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
            } else {
                tagLabel.text = lecture!.tagDescription
            }
            timeLabel.text = lecture!.timeDescription
            placeLabel.text = lecture!.placeDescription
        }
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        tableView.deselectRowAtIndexPath(tableView.indexPathForCell(self)!, animated: true)
        STTimetableManager.sharedInstance.addLecture(lecture!, object: self)
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
            tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
        } else {
            self.backgroundColor = UIColor.clearColor()
            addButton.hidden = true
            tagLabel.text = lecture?.tagDescription
        }
        
        // Configure the view for the selected state
    }


}
