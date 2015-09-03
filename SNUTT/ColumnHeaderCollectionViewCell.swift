//
//  ColumnHeaderCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class ColumnHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
