//
//  STSlotCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STSlotCellCollectionViewCell: UICollectionViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    var rowNum = 0
    var columnNum = 0
    var ratioForHeader : CGFloat = 0.0
    var context = UIGraphicsGetCurrentContext()
    
    func drawSolidLine(st_x st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat) {
        CGContextSetLineDash(context!, 0, [1], 0)
        CGContextSetLineWidth(context!, 0.2)
        CGContextMoveToPoint(context!, st_x, st_y)
        CGContextAddLineToPoint(context!, en_x, en_y)
        CGContextStrokePath(context!)
    }
    
    func drawDashedLine(st_x st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat) {
        CGContextSetLineDash(context!, 0, [2,2], 2)
        CGContextSetLineWidth(context!, 0.4)
        CGContextMoveToPoint(context!, st_x, st_y)
        CGContextAddLineToPoint(context!, en_x, en_y)
        CGContextStrokePath(context!)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context!, CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.4,0.4,0.4,1.0])!)
        
        let contentWidth = rect.width
        let contentHeight = rect.height
        
        let widthPerColumn = contentWidth / CGFloat(columnNum)
        let heightPerRow = contentHeight / (CGFloat(rowNum) + ratioForHeader)
        let heightForHeader = ratioForHeader * heightPerRow
        /*
        for i in 1..<columnNum {
            let x = widthPerColumn * CGFloat(i)
            drawSolidLine(st_x: x, st_y: 0, en_x: x, en_y: contentHeight)
        }
        */
        for i in 0..<(rowNum*2) {
            let y = heightForHeader + heightPerRow * CGFloat(i) / 2.0
            if i % 2 == 0 {
                drawSolidLine(st_x: 20.0, st_y: y, en_x: contentWidth, en_y: y)
            } else {
                //drawDashedLine(st_x: widthPerColumn, st_y: y, en_x: contentWidth, en_y: y)
            }
        }
    }
}
