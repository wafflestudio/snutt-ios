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
    @IBOutlet weak var profLabel: UILabel!
    @IBOutlet weak var tagLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var addButton: STViewButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var viewForSelected: UIView!
    @IBOutlet weak var
        addButtonLabel: UILabel!
    
    @IBAction func showSyllabus(_ sender: UIButton) {
        openSyllabus()
    }
    
    @IBAction func showReview(_ sender: UIButton) {
        STAlertView.showAlert(title: "준비중입니다", message: "")
    }
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var syllabusButton: UIButton!
    
    private func openSyllabus() {
        if let url = syllabusUrl {
            showWebView(url)
        }
    }
    
    var quarter: STQuarter?
    var syllabusUrl: String?
    weak var tableView : UITableView!
    
    func indexInTimetable() -> Int {
        guard let lecture = lecture else {
            return -1
        }
        let index = STTimetableManager.sharedInstance.currentTimetable?.indexOf(lecture: lecture) ?? -1
        return index
    }
    
    var lecture : STLecture? {
        didSet {
            titleLabel.text = lecture!.title == "" ? "강좌명" : lecture!.title
            titleLabel.textColor = lecture!.title == "" ? UIColor(white: 1.0, alpha: 0.7) : UIColor(white: 1.0, alpha: 1.0)
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
        profLabel.text = lecture.instructor
        descriptionLabel.text = (lecture.instructor == "" ? "" : "/ ") + "\(lecture.credit)학점"
    }
    
    func setUp() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        titleLabel.trailingBuffer = 10.0
        tagLabel.trailingBuffer = 10.0
        titleLabel.animationDelay = 0.3
        tagLabel.animationDelay = 0.3
        
        addButton.buttonPressAction = {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
            self.tableView.deselectRow(at: self.tableView.indexPath(for: self)!, animated: true)
            let index = self.indexInTimetable()
            if index >= 0{
                STTimetableManager.sharedInstance.deleteLectureAtIndex(index, object: self)
            } else {
                STTimetableManager.sharedInstance.addLecture(self.lecture!, object: self)
            }
            self.setAddButton()
            self.tableView.performBatchUpdates(nil, completion: nil)
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
        self.frame.size.height = 106
        viewForSelected.isHidden = true
        setUp()
        syllabusButton.isHidden = true
        reviewButton.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            setAddButton()
            addButton.isHidden = false
            reviewButton.isHidden = false
            tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
            getSyllabus()
        } else {
            self.backgroundColor = UIColor.clear
            addButton.isHidden = true
            syllabusButton.isHidden = true
            reviewButton.isHidden = true
            viewForSelected.isHidden = false
            tagLabel.text = lecture?.tagDescription
        }
        titleLabel.labelize = !selected
        tagLabel.labelize = !selected
        setDescLabel()
        self.frame.size.height = 150
    }
    
    private func showWebView(_ url: String) {
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    private func getSyllabus() {
        if let quarter = quarter, let lecture = lecture {
            STNetworking.getSyllabus(quarter, lecture: lecture, done: { url in
                self.syllabusUrl = url
                self.syllabusButton.isHidden = false
            }) {
            }
        }
    }
}

