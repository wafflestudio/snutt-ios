//
//  CourseDataSource.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class CourseDataSource: NSObject, UICollectionViewDataSource {
    var ColumnList = ["","월", "화", "수", "목", "금", "토"]
    var RowList : [String] = []
    
    var CourseList : [STLecture] = []
    var SingleClassList : [STSingleClass] = []
    
    override init() {
        var lecture = STLecture(name: "컴퓨터 개론 및 실습", professor: "문병로", classList: [STSingleClass(startTime: STTime(day: STTime.STDay.MON, period: 3), duration: 2, place: "003-104")])
        CourseList.append(lecture)
        SingleClassList.append(lecture.classList[0])
        RowList.append("")
        for i in 0..<(STTime.periodNum) {
            var startTime = STTime(day: STTime.STDay.MON, period: i*2)
            var endTime = STTime(day: STTime.STDay.MON, period: i*2+1)
            RowList.append("\(startTime.periodToString()) ~ \(endTime.periodToString())")
        }
    }
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ColumnList.count * RowList.count
        case 1:
            return SingleClassList.count
        default:
            return 0
        }
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch getCellType(indexPath) {
        case .HeaderColumn:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! ColumnHeaderCollectionViewCell
            cell.contentLabel.text = ColumnList[indexPath.row]
            return cell
        case .HeaderRow:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColumnHeaderCell", forIndexPath: indexPath) as! ColumnHeaderCollectionViewCell
            cell.contentLabel.text = RowList[indexPath.row / ColumnList.count]
            return cell
        case .Slot:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SlotCell", forIndexPath: indexPath) as! UICollectionViewCell;
            return cell
        case .Course:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as!CourseCellCollectionViewCell
            var course = SingleClassList[indexPath.row]
            cell.setSingleClass(course)
            return cell
        }
    }
    enum cellType{
    case HeaderColumn, HeaderRow, Slot, Course
    }
    func getCellType(indexPath : NSIndexPath) -> cellType {
        if indexPath.section == 1 {
            return cellType.Course
        } else {
            if indexPath.row < ColumnList.count {
                return cellType.HeaderColumn
            } else if indexPath.row % ColumnList.count == 0 {
                return cellType.HeaderRow
            } else {
                return cellType.Slot
            }
        }
    }
}
