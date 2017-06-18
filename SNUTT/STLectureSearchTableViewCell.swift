//
//  STLectureSearchTableViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import MarqueeLabel

class STLectureSearchTableViewCell: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var addButton: STViewButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var addButtonLabel: UILabel!
    weak var tableView : UITableView!

    @IBOutlet weak var constraintForHidden: NSLayoutConstraint!
    @IBOutlet weak var constraintForShown: NSLayoutConstraint!

    func indexInTimetable() -> Int {
        let index = STTimetableManager.sharedInstance.currentTimetable?.indexOf(lecture: lecture!) ?? -1
        return index
    }

    var lecture : STLecture? {
        didSet {
            titleLabel.text = lecture?.title
            if self.isSelected {
                tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
            } else {
                tagLabel.text = lecture!.tagDescription
            }
            timeLabel.text = lecture!.timeDescription
            placeLabel.text = lecture!.placeDescription
            setAddButton()
            setDescLabel()
        }
    }

    func setDescLabel() {
        guard let lecture = lecture else {
            return
        }
        var instructorText = lecture.instructor
        let isSE = !isLargerThanSE()
        var length = 0
        if self.isSelected {
            if instructorText.isEnglish() {
                length = isSE ? 6 : 8
            } else {
                length = isSE ? 3 : 4
            }
        } else {
            if instructorText.isEnglish() {
                length = isSE ? 13 : 15
            } else {
                length = isSE ? 7 : 9
            }
        }
        instructorText = instructorText.trunc(length: length)
        descriptionLabel.text = "\(instructorText)/\(lecture.credit)학점"
    }

    func setUp() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        titleLabel.trailingBuffer = 10.0
        tagLabel.trailingBuffer = 10.0
        titleLabel.animationDelay = 0.3
        tagLabel.animationDelay = 0.3
        addButton.buttonPressAction = { _ in
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
            self.tableView.deselectRow(at: self.tableView.indexPath(for: self)!, animated: true)
            let index = self.indexInTimetable()
            if index >= 0{
                STTimetableManager.sharedInstance.deleteLectureAtIndex(index, object: self)
            } else {
                STTimetableManager.sharedInstance.addLecture(self.lecture!, object: self)
            }
            self.setAddButton()
        }
    }

    func setAddButton() {
        let index = indexInTimetable()
        if index < 0 {
            addButtonLabel.text = "+ 추가하기"
        } else {
            addButtonLabel.text = "제거하기"
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            setAddButton()
            addButton.isHidden = false
            tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
        } else {
            self.backgroundColor = UIColor.clear
            addButton.isHidden = true
            tagLabel.text = lecture?.tagDescription
        }
        titleLabel.labelize = !selected
        tagLabel.labelize = !selected
        // 800, 790 is because of priority in content wrapping
        constraintForHidden.priority = !selected ? UILayoutPriority(800):UILayoutPriority(790)
        constraintForShown.priority = selected ? UILayoutPriority(800):UILayoutPriority(790)
        setDescLabel()
        // Configure the view for the selected state
    }


}
