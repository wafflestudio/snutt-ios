//
//  TimeTableLayout.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class TimeTableLayout: UICollectionViewLayout {
    var HeightForHeader : CGFloat = 20.0
    var HeightPerHour : CGFloat = 40
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var ret : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        var source = collectionView?.dataSource as! CourseDataSource
        var type = source.getCellType(indexPath)
        if type == CourseDataSource.cellType.Course {
            var singleClass = source.SingleClassList[indexPath.row]
            var indexRow = CGFloat(singleClass.startTime.period) / 2.0
            var indexColumn = singleClass.startTime.day.rawValue
            var width = self.collectionView!.bounds.size.width / CGFloat(source.ColumnList.count)
            var height = HeightPerHour * CGFloat(singleClass.duration) / 2.0
            var locX = CGFloat(indexColumn+1) * width
            var locY = HeightForHeader + HeightPerHour * indexRow
            ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        } else {
            var indexRow = indexPath.row / source.ColumnList.count
            var indexColumn = indexPath.row % source.ColumnList.count
            var width = self.collectionView!.bounds.size.width / CGFloat(source.ColumnList.count)
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
            var locX = CGFloat(indexColumn) * width
            var locY : CGFloat = 0.0
            if indexRow == 0 {
                locY = 0
            } else {
                locY = HeightForHeader + HeightPerHour * CGFloat(indexRow - 1)
            }
            ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        }
        return ret
    }
    override func collectionViewContentSize() -> CGSize {
        var contentWidth = self.collectionView!.bounds.size.width
        var contentHeight: CGFloat = CGFloat(HeightForHeader + (HeightPerHour * CGFloat(STTime.periodNum)))
        return CGSize(width: contentWidth, height: contentHeight)
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var ret : [AnyObject]? = []
        var source = collectionView?.dataSource as! CourseDataSource
        for i in 0..<(source.numberOfSectionsInCollectionView(collectionView!)) {
            for j in 0..<(source.collectionView(collectionView!, numberOfItemsInSection: i)) {
                var indexPath = NSIndexPath(forRow: j, inSection: i)
                ret?.append(self.layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        return ret
    }
}
