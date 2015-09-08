//
//  STSlotCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STSlotCellCollectionViewCell: UICollectionViewCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.6,0.6,0.6,1.0]))
        CGContextSetLineDash(context, 0, [2,2], 2)
        CGContextSetLineWidth(context, 0.4)
        CGContextMoveToPoint(context, 0.0, (rect.height-1.0)/2.0)
        CGContextAddLineToPoint(context, (rect.width-1.0), (rect.height-1.0)/2.0)
        CGContextStrokePath(context)
        
        CGContextSetLineDash(context, 0, [1], 0)
        CGContextSetLineWidth(context, 0.3)
        CGContextMoveToPoint(context, 0.0, rect.height-1.0)
        CGContextAddLineToPoint(context, rect.width-1.0, rect.height-1.0)
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, rect.width-1.0, 0)
        CGContextAddLineToPoint(context, rect.width-1.0, rect.height-1.0)
        CGContextStrokePath(context)
        
        
    }
}
