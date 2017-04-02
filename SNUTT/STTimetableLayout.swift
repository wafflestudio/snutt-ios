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

    var timetableView : STTimetableCollectionView!
    
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        
        let ret : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let type = timetableView!.getCellType(indexPath)
        
        var width : CGFloat
        var height : CGFloat
        var locX : CGFloat
        var locY : CGFloat
        
        switch type {
        case .course, .temporaryCourse:
            let singleClass = timetableView.getSingleClass(indexPath)
            let rowIndex = CGFloat(timetableView.getRowFromPeriod(singleClass.time.startPeriod))
            let columnIndex = timetableView.dayToColumn[singleClass.time.day.rawValue]
            
            width = WidthPerColumn
            height = HeightPerRow * CGFloat(singleClass.time.duration) + 0.4
            locX = CGFloat(columnIndex) * WidthPerColumn + WidthForHeader
            locY = HeightForHeader + HeightPerRow * rowIndex - 0.2
        case .headerColumn:
            width = WidthPerColumn
            height = HeightForHeader
            let columnIndex = timetableView.dayToColumn[indexPath.row]
            locX = CGFloat(columnIndex) * WidthPerColumn + WidthForHeader
            locY = CGFloat(0)
        case .headerRow:
            width = WidthForHeader
            height = HeightPerRow
            locX = CGFloat(0)
            let rowIndex = CGFloat(timetableView.getRowFromPeriod(Double(indexPath.row)))
            locY = HeightForHeader + rowIndex * HeightPerRow
        case .slot:
            width = ContentWidth
            height = ContentHeight
            locX = CGFloat(0)
            locY = CGFloat(0)
        }
        ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
        return ret
    }
    override var collectionViewContentSize : CGSize {
        updateContentSize()
        return CGSize(width: ContentWidth, height: ContentHeight)
    }
    
    func updateContentSize() {
        ContentWidth = self.collectionView!.bounds.size.width
        ContentHeight = self.collectionView!.bounds.size.height

        WidthPerColumn = (ContentWidth - WidthForHeader) / CGFloat(timetableView.columnNum)
        HeightPerRow = ContentHeight / (CGFloat(timetableView.rowNum) + timetableView!.RatioForHeader)
        HeightForHeader = timetableView!.RatioForHeader * HeightPerRow
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var ret : [UICollectionViewLayoutAttributes] = []
        for i in 0..<(timetableView!.numberOfSections(in: collectionView!)) {
            for j in 0..<(timetableView!.collectionView(collectionView!, numberOfItemsInSection: i)) {
                let indexPath = IndexPath(row: j, section: i)
                ret.append(self.layoutAttributesForItem(at: indexPath))
            }
        }
        return ret.map({ attribute in
            let type = self.timetableView.getCellType(attribute.indexPath);
            switch (type) {
            case .slot: attribute.zIndex = -1
            case .course: attribute.zIndex = 0
            case .temporaryCourse: attribute.zIndex = 1
            case .headerRow, .headerColumn: attribute.zIndex = 2
            }
            return attribute
        })
        /*
        
        */
    }
}
