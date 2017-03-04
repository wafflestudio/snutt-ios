//
//  STTimetableLayout.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableLayout: UICollectionViewLayout {
    var ContentWidth : CGFloat = 0.0
    var ContentHeight : CGFloat = 0.0
    
    var HeightForHeader : CGFloat = 0.0
    var HeightPerRow : CGFloat = 0.0
    var WidthForHeader : CGFloat = 0.0
    var WidthPerColumn : CGFloat = 0.0
    
    var controller : STTimetableCollectionViewController!
    
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        
        let ret : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let type = controller!.getCellType(indexPath)
        
        var width : CGFloat
        var height : CGFloat
        var locX : CGFloat
        var locY : CGFloat
        
        switch type {
        case .Course, .TemporaryCourse:
            let singleClass = controller.getSingleClass(indexPath)
            let rowIndex = CGFloat(controller.getRowFromPeriod(singleClass.time.startPeriod))
            let columnIndex = controller.dayToColumn[singleClass.time.day.rawValue]
            
            width = WidthPerColumn
            height = HeightPerRow * CGFloat(singleClass.time.duration) + 0.4
            locX = CGFloat(columnIndex) * WidthPerColumn + WidthForHeader
            locY = HeightForHeader + HeightPerRow * rowIndex - 0.2
        case .HeaderColumn:
            width = WidthPerColumn
            height = HeightForHeader
            let columnIndex = controller.dayToColumn[indexPath.row]
            locX = CGFloat(columnIndex) * WidthPerColumn + WidthForHeader
            locY = CGFloat(0)
        case .HeaderRow:
            width = WidthForHeader
            height = HeightPerRow
            locX = CGFloat(0)
            let rowIndex = CGFloat(controller.getRowFromPeriod(Double(indexPath.row)))
            locY = HeightForHeader + rowIndex * HeightPerRow
        case .Slot:
            width = ContentWidth
            height = ContentHeight
            locX = CGFloat(0)
            locY = CGFloat(0)
        }
        ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        return ret
    }
    override func collectionViewContentSize() -> CGSize {
        updateContentSize()
        return CGSize(width: ContentWidth, height: ContentHeight)
    }
    
    func updateContentSize() {
        ContentWidth = self.collectionView!.bounds.size.width
        ContentHeight = self.collectionView!.bounds.size.height

        WidthPerColumn = (ContentWidth - WidthForHeader) / CGFloat(controller.columnNum)
        HeightPerRow = ContentHeight / (CGFloat(controller.rowNum) + controller!.RatioForHeader)
        HeightForHeader = controller!.RatioForHeader * HeightPerRow
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var ret : [UICollectionViewLayoutAttributes] = []
        for i in 0..<(controller!.numberOfSectionsInCollectionView(collectionView!)) {
            for j in 0..<(controller!.collectionView(collectionView!, numberOfItemsInSection: i)) {
                let indexPath = NSIndexPath(forRow: j, inSection: i)
                ret.append(self.layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        return ret.map({ attribute in
            let type = self.controller.getCellType(attribute.indexPath);
            switch (type) {
            case .Slot: attribute.zIndex = -1
            case .Course: attribute.zIndex = 0
            case .TemporaryCourse: attribute.zIndex = 1
            case .HeaderRow, .HeaderColumn: attribute.zIndex = 2
            }
            return attribute
        })
        /*
        
        */
    }
}
