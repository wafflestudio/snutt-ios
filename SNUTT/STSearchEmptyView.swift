//
//  STSearchEmptyView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 6. 11..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchEmptyView: UIView {

    @IBOutlet weak var helpViewButton: STViewButton!
    weak var searchController: STLectureSearchTableViewController!

    override func awakeFromNib() {
        helpViewButton.buttonPressAction = { _ in
            self.searchController.showInfo = true
            self.searchController.tableView.reloadEmptyDataSet()
        }
    }
}
