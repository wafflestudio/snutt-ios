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
            if isSelectedTag {
                tagLabel.textColor = tagType.tagColor
            } else {
                tagLabel.textColor = tagType.tagColor.colorWithAlphaComponent(0.5)
            }
            tagLabel.text = tagType.typeStr
        }
    }
    var isSelectedTag : Bool = false {
        didSet {
            if isSelectedTag {
                tagLabel.textColor = tagType.tagColor
            } else {
                tagLabel.textColor = tagType.tagColor.colorWithAlphaComponent(0.5)
            }
        }
    }
    
}
