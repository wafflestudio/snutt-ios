//
//  STLectureSearchTableViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import MarqueeLabel
import UIKit

class STLectureSearchTableViewCell: UITableViewCell, UIAlertViewDelegate {
    @IBOutlet var titleLabel: MarqueeLabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profLabel: UILabel!
    @IBOutlet var tagLabel: MarqueeLabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var containerView: UIView!

    @IBOutlet var viewForSelected: UIView!

    @IBAction func showSyllabus(_: UIButton) {
        openSyllabus()
    }

    @IBAction func showReview(_: UIButton) {
        guard let lecture = lecture else {
            print("Error: lecure is nil")
            return
        }

        guard let courseNumber = lecture.courseNumber else {
            print("Error: course number is nil")
            return
        }

        STNetworking.getReviewIdFromLecture(courseNumber, lecture.instructor) { id in
            self.moveToReviewDetail?(id)

        } failure: {
            STAlertView.showAlert(title: "", message: "강의평을 찾을 수 없습니다")
        }
    }

    @IBAction func add(_: UIButton) {
        STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        tableView.deselectRow(at: tableView.indexPath(for: self)!, animated: true)
        let index = indexInTimetable()
        if index >= 0 {
            STTimetableManager.sharedInstance.deleteLectureAtIndex(index, object: self)
        } else {
            STTimetableManager.sharedInstance.addLecture(lecture!, object: self)
        }
        setAddButton()
        tableView.performBatchUpdates(nil, completion: nil)
    }

    @IBOutlet var reviewButton: UIButton!
    @IBOutlet var syllabusButton: UIButton!

    var moveToReviewDetail: ((_ withId: String) -> Void)?

    private func openSyllabus() {
        if let url = syllabusUrl {
            showWebView(url)
        }
    }

    var quarter: STQuarter?
    var syllabusUrl: String?
    weak var tableView: UITableView!

    func indexInTimetable() -> Int {
        guard let lecture = lecture else {
            return -1
        }
        let index = STTimetableManager.sharedInstance.currentTimetable?.indexOf(lecture: lecture) ?? -1
        return index
    }

    var lecture: STLecture? {
        didSet {
            titleLabel.text = lecture!.title == "" ? "강좌명" : lecture!.title
            titleLabel.textColor = lecture!.title == "" ? UIColor(white: 1.0, alpha: 0.7) : UIColor(white: 1.0, alpha: 1.0)
            if isSelected {
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
        backgroundColor = UIColor.clear
        selectionStyle = .none
        titleLabel.trailingBuffer = 10.0
        tagLabel.trailingBuffer = 10.0
        titleLabel.animationDelay = 0.3
        tagLabel.animationDelay = 0.3
    }

    func setAddButton() {
        let index = indexInTimetable()
        if index < 0 {
            addButton.setTitle("+ 추가하기", for: .normal)
        } else {
            addButton.setTitle("제거하기", for: .normal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        frame.size.height = 106
        viewForSelected.isHidden = true
        setUp()
        syllabusButton.isHidden = true
        reviewButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            setAddButton()
            addButton.isHidden = false
            reviewButton.isHidden = false
            tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
            getSyllabus()
        } else {
            backgroundColor = UIColor.clear
            addButton.isHidden = true
            syllabusButton.isHidden = true
            reviewButton.isHidden = true
            viewForSelected.isHidden = false
            tagLabel.text = lecture?.tagDescription
        }
        titleLabel.labelize = !selected
        tagLabel.labelize = !selected
        setDescLabel()
        frame.size.height = 150
    }

    private func showWebView(_ url: String) {
        UIApplication.shared.openURL(URL(string: url)!)
    }

    private func getSyllabus() {
        if let quarter = quarter, let lecture = lecture {
            STNetworking.getSyllabus(quarter, lecture: lecture, done: { url in
                self.syllabusUrl = url
                self.syllabusButton.isHidden = false
            }) {}
        }
    }
}
