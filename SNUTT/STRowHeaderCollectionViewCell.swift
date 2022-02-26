//
//  STRowHeaderCollectionViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 30..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STRowHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }
}
