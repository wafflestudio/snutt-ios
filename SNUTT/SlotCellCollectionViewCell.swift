//
//  SlotCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class SlotCellCollectionViewCell: UICollectionViewCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 0.3
        layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.7,0.7,0.7,1.0])
    }
}
