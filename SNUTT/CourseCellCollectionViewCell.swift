//
//  CourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class CourseCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var courseText: UILabel!
    var singleClass : STSingleClass?
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 10
        
    }
    func setSingleClass(tmp : STSingleClass) {
        singleClass = tmp
        courseText.text = "\(tmp.lecture!.name) \(tmp.place)"
    }
}
