//
//  STSearchEmptyInfoView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 6. 11..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchEmptyInfoView: UIView {
    @IBOutlet var searchIcon: UIImageView!
    weak var searchController: STLectureSearchTableViewController!

    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleIconTap))
        searchIcon.addGestureRecognizer(tapGesture)
        searchIcon.isUserInteractionEnabled = true
    }

    @objc func handleIconTap(sender _: UITapGestureRecognizer) {
        searchController.setFocusToSearch()
    }
}
