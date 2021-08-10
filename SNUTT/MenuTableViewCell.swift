//
//  MenuTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/05.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate: class {
    func showSettingSheet(_ cell: MenuTableViewCell)
    func updateTableViewData(_ cell: MenuTableViewCell, timetableList: [STTimetable])
}

class MenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        timetableLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 105).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var delegate: MenuTableViewCellDelegate?
    var timetable: STTimetable?
    
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var timetableLabel: UILabel!
    @IBOutlet weak var checkedIcon: UIImageView!
    
    @IBAction func duplicateButton(_ sender: UIButton) {
        guard let timetable = timetable, let id = timetable.id else { return }
        STNetworking.copyTimetable(id: id) { timetableList in
            self.delegate?.updateTableViewData(self, timetableList: timetableList)
        } failure: { errorCode in
            STAlertView.showAlert(title: "시간표 복사 실패", message: errorCode.errorMessage)
        }
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
        delegate?.showSettingSheet(self)
    }
    
    @IBOutlet weak var duplicateBButton: UIButton!
    @IBOutlet weak var settingBButton: UIButton!
    
    func setLabel(text: String) {
        timetableLabel.text = text
    }
    
    func setCredit(credit: Int) {
        credits.text = "(" + String(credit) + " 학점)"
    }
    
    func setCreateNewCellStyle() {
        credits.isHidden = true
        checkedIcon.isHidden = true
        timetableLabel.textColor = .gray
        duplicateBButton.isHidden = true
        settingBButton.isHidden = true
    }
    
    func setDefaultCellStyle() {
        credits.isHidden = false
        checkedIcon.isHidden = false
        timetableLabel.textColor = .black
        duplicateBButton.isHidden = false
        settingBButton.isHidden = false
    }
    
    func hideCheckIcon() {
        checkedIcon.isHidden = true
    }
    
    func showCheckIcon() {
        checkedIcon.isHidden = false
    }
}
