//
//  MenuTableViewHeaderView.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/07.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol MenuTableViewHeaderViewDelegate: class {
    func presentSemesterPickView(_: MenuTableViewHeaderView)
}

class MenuTableViewHeaderView: UITableViewHeaderFooterView {
    weak var delegate: MenuTableViewHeaderViewDelegate?

    @IBAction func chooseSemester(_: UIButton) {
        delegate?.presentSemesterPickView(self)
    }

    @IBAction func chooseSemesterOnLabel(_: UIButton) {
        delegate?.presentSemesterPickView(self)
    }

    @IBOutlet weak var headerLabelButton: UIButton!

    func setHeaderLabel(text: String) {
        headerLabelButton.setTitle(text, for: .normal)
    }
}
