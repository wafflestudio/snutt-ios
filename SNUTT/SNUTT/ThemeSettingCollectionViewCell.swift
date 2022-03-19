//
//  ThemeSettingCollectionViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/31.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class ThemeSettingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var themeImage: UIImageView!
    @IBOutlet weak var themeLabel: UILabel! {
        didSet {
            themeLabel.layer.cornerRadius = 10
            themeLabel.clipsToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setThemeImage(_ image: UIImage) {
        themeImage.image = image
    }

    func setLabelText(_ text: String) {
        themeLabel.text = text
    }

    func setThemeSelected() {
        themeLabel.backgroundColor = UIColor(hexString: "#F2F2F2")
    }

    func setThemeDeselected() {
        themeLabel.backgroundColor = nil
    }
}
