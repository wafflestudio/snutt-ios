//
//  STTextViewTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STTextViewTableViewCell: STLectureDetailTableViewCell, UITextViewDelegate {
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var textView: UITextView!

    var doneBlock: ((String) -> Void)?
    weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        doneBlock?(textView.text)
    }

    func textViewDidChange(_ textView: UITextView) {
        doneBlock?(textView.text)
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func setEditable(_ editable: Bool) {
        textView.isEditable = editable
    }
}
