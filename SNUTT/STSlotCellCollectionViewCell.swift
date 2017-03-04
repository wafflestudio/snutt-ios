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
    var widthForHeader : CGFloat = 0
    var ratioForHeader : CGFloat = 0.0
    var context = UIGraphicsGetCurrentContext()
    
    func drawSolidLine(st_x st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 0.2) {
        CGContextSetLineDash(context!, 0, [1], 0)
        CGContextSetLineWidth(context!, width)
        CGContextMoveToPoint(context!, st_x, st_y)
        CGContextAddLineToPoint(context!, en_x, en_y)
        CGContextStrokePath(context!)
    }
    
    func drawDashedLine(st_x st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 0.4) {
        CGContextSetLineDash(context!, 0, [2,2], 2)
        CGContextSetLineWidth(context!, width)
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
        
        let widthPerColumn = (contentWidth - widthForHeader) / CGFloat(columnNum)
        let heightPerRow = contentHeight / (CGFloat(rowNum) + ratioForHeader)
        let heightForHeader = ratioForHeader * heightPerRow

        // horizontal line

        let darkgrayColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.55,0.55,0.55,1.0])!
        let grayColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.7,0.7,0.7,1.0])!
        for i in 0..<(rowNum*2) {
            let y = heightForHeader + heightPerRow * CGFloat(i) / 2.0
            if i % 2 == 0 {
                CGContextSetStrokeColorWithColor(context!, darkgrayColor)
                drawSolidLine(st_x: widthForHeader / 2.0, st_y: y, en_x: contentWidth, en_y: y)
            } else {
                CGContextSetStrokeColorWithColor(context!, grayColor)
                drawDashedLine(st_x: widthForHeader, st_y: y, en_x: contentWidth, en_y: y)
            }
        }

        CGContextSetStrokeColorWithColor(context!, CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.55,0.55,0.55,1.0])!)

        // vertical line
        for i in 0..<columnNum {
            let x = widthForHeader + widthPerColumn * CGFloat(i)
            drawSolidLine(st_x: x, st_y: 0, en_x: x, en_y: contentHeight, width: 0.15)
        }
    }
}
