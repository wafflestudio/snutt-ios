//
//  STTagFilterCollectionViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 5..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    
    var tagType : STTagType! {
        didSet {
            tagLabel.textColor = tagType.tagColor
            tagLabel.text = tagType.typeStr
        }
    }
    var isSelectedTag : Bool = false {
        didSet {
            if isSelectedTag {
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
}
