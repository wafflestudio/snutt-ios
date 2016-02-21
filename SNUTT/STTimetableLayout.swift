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
    
    var timetableController : STTimetableCollectionViewController? = nil
    var timetable : STTimetable?
    
    init (aTimetable :STTimetable?) {
        self.timetable = aTimetable
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        
        let ret : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let type = timetableController!.getCellType(indexPath)
        
        var width : CGFloat
        var height : CGFloat
        var locX : CGFloat
        var locY : CGFloat
        
        switch type {
        case .Course, .TemporaryCourse:
            let singleClass = timetableController!.getSingleClass(indexPath)
            let indexRow = CGFloat(singleClass.time.startPeriod)
            let indexColumn = singleClass.time.day.rawValue
            width = WidthPerColumn
            height = HeightPerRow * CGFloat(singleClass.time.duration)
            locX = CGFloat(indexColumn+1) * width
            locY = HeightForHeader + HeightPerRow * indexRow
        case .HeaderColumn:
            width = WidthPerColumn
            height = HeightForHeader
            locX = CGFloat(indexPath.row + 1) * WidthPerColumn
            locY = CGFloat(0)
        case .HeaderRow:
            width = WidthPerColumn
            height = HeightPerRow
            locX = CGFloat(0)
            locY = HeightForHeader + CGFloat(indexPath.row) * HeightPerRow
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
        ContentWidth = self.collectionView!.bounds.size.width
        ContentHeight = self.collectionView!.bounds.size.height
        
        WidthPerColumn = ContentWidth / CGFloat(timetableController!.columnList.count + 1)
        HeightPerRow = ContentHeight / (CGFloat(STTime.periodNum) + timetableController!.RatioForHeader)
        HeightForHeader = timetableController!.RatioForHeader * HeightPerRow
        
        return CGSize(width: ContentWidth, height: ContentHeight)
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var ret : [UICollectionViewLayoutAttributes]? = []
        for i in 0..<(timetableController!.numberOfSectionsInCollectionView(collectionView!)) {
            for j in 0..<(timetableController!.collectionView(collectionView!, numberOfItemsInSection: i)) {
                let indexPath = NSIndexPath(forRow: j, inSection: i)
                ret?.append(self.layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        return ret
    }
}
