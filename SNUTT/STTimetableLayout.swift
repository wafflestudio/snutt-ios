//
//  STTimetableLayout.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableLayout: UICollectionViewLayout {
    var HeightForHeader : CGFloat = 20.0
    var HeightPerHour : CGFloat = 34
    var ratioForHeader : CGFloat = 2.0/3.0
    var timeTableController : STTimetableCollectionViewController? = nil
    var timetable : STTimetable?
    
    init (aTimetable :STTimetable?) {
        self.timetable = aTimetable
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        
        HeightPerHour = collectionView!.frame.size.height / (CGFloat(STTime.periodNum) + ratioForHeader)
        HeightForHeader = ratioForHeader * HeightPerHour
        
        let ret : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let type = timeTableController!.getCellType(indexPath)
        if type == STTimetableCollectionViewController.cellType.Course {
            let singleClass = timetable!.singleClassList[indexPath.row]
            let indexRow = CGFloat(singleClass.startTime.period) / 2.0
            let indexColumn = singleClass.startTime.day.rawValue
            let width = self.collectionView!.bounds.size.width / CGFloat(timeTableController!.columnList.count)
            let height = HeightPerHour * CGFloat(singleClass.duration) / 2.0
            let locX = CGFloat(indexColumn+1) * width
            let locY = HeightForHeader + HeightPerHour * (indexRow-1.0)
            ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        } else {
            let indexRow = indexPath.row / timeTableController!.columnList.count
            let indexColumn = indexPath.row % timeTableController!.columnList.count
            var width = self.collectionView!.bounds.size.width / CGFloat(timeTableController!.columnList.count)
            var height : CGFloat = 0.0
            switch type {
            case .HeaderColumn:
                height = HeightForHeader
            case .HeaderRow:
                height = HeightPerHour
            case .Slot:
                height = HeightPerHour
            default:
                height = 0.0
            }
            let locX = CGFloat(indexColumn) * width
            var locY : CGFloat = 0.0
            if indexRow == 0 {
                locY = 0
            } else {
                locY = HeightForHeader + HeightPerHour * CGFloat(indexRow - 1)
            }
            if type == STTimetableCollectionViewController.cellType.Slot {
                width = width + 1.0
                height = height + 1.0
            }
            ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        }
        return ret
    }
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = self.collectionView!.bounds.size.width
        let contentHeight: CGFloat = self.collectionView!.bounds.size.height
        return CGSize(width: contentWidth, height: contentHeight)
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var ret : [UICollectionViewLayoutAttributes]? = []
        for i in 0..<(timeTableController!.numberOfSectionsInCollectionView(collectionView!)) {
            for j in 0..<(timeTableController!.collectionView(collectionView!, numberOfItemsInSection: i)) {
                let indexPath = NSIndexPath(forRow: j, inSection: i)
                ret?.append(self.layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        return ret
    }
}
