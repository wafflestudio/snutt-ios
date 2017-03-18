//
//  STTextViewTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STTextViewTableViewCell: STLectureDetailTableViewCell, UITextViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var textView: UITextView!

    var doneBlock: ((String)->())?
    weak var tableView : UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsetsZero
    }

    func textViewDidEndEditing(textView: UITextView) {
        doneBlock?(textView.text)
    }

    func textViewDidChange(textView: UITextView) {
        doneBlock?(textView.text)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    override func setEditable (editable: Bool) {
        textView.editable = editable
    }

}
