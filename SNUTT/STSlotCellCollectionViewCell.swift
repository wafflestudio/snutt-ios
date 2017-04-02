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
    
    func drawSolidLine(st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 0.2) {
        context!.setLineDash(phase: 0.0, lengths: [1.0])
        context!.setLineWidth(width)
        context!.move(to: CGPoint(x: st_x, y: st_y))
        context!.addLine(to: CGPoint(x: en_x, y: en_y))
        context!.strokePath()
    }
    
    func drawDashedLine(st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 0.4) {
        context!.setLineDash(phase: 0.0, lengths: [2.0, 2.0])
        context!.setLineWidth(width)
        context!.move(to: CGPoint(x: st_x, y: st_y))
        context!.addLine(to: CGPoint(x: en_x, y: en_y))
        context!.strokePath()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor(CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.4,0.4,0.4,1.0])!)
        
        let contentWidth = rect.width
        let contentHeight = rect.height
        
        let widthPerColumn = (contentWidth - widthForHeader) / CGFloat(columnNum)
        let heightPerRow = contentHeight / (CGFloat(rowNum) + ratioForHeader)
        let heightForHeader = ratioForHeader * heightPerRow

        // horizontal line

        let darkgrayColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.55,0.55,0.55,1.0])!
        let grayColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.7,0.7,0.7,1.0])!
        for i in 0..<(rowNum*2) {
            let y = heightForHeader + heightPerRow * CGFloat(i) / 2.0
            if i % 2 == 0 {
                context!.setStrokeColor(darkgrayColor)
                drawSolidLine(st_x: widthForHeader / 2.0, st_y: y, en_x: contentWidth, en_y: y)
            } else {
                context!.setStrokeColor(grayColor)
                drawDashedLine(st_x: widthForHeader, st_y: y, en_x: contentWidth, en_y: y)
            }
        }

        context!.setStrokeColor(CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.55,0.55,0.55,1.0])!)

        // vertical line
        for i in 0..<columnNum {
            let x = widthForHeader + widthPerColumn * CGFloat(i)
            drawSolidLine(st_x: x, st_y: 0, en_x: x, en_y: contentHeight, width: 0.15)
        }
    }
}
