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
    var collectionView : UICollectionView? = nil
    override init() {
        RowList.append("")
        for i in 0..<(STTime.periodNum) {
            var startTime = STTime(day: STTime.STDay.MON, period: i*2)
            var endTime = STTime(day: STTime.STDay.MON, period: i*2+1)
            RowList.append("\(startTime.periodToString()) ~ \(endTime.periodToString())")
        }
    }
    enum AddLectureState {
        case Success, ErrorTime, ErrorSameLecture
    }
    func addLecture(lecture : STLecture) -> AddLectureState {
        for it in CourseList {
            if it.isEquals(lecture){
                return AddLectureState.ErrorSameLecture
            }
        }
        for it in SingleClassList {
            for jt in lecture.classList {
                if it.isOverlappingWith(jt) {
                    return AddLectureState.ErrorTime
                }
            }
        }
        CourseList.append(lecture)
        for it in lecture.classList {
            SingleClassList.append(it)
        }
        collectionView?.reloadData()
        return AddLectureState.Success
    }
    func deleteLecture(lecture : STLecture) {
        for (var i=0; i<SingleClassList.count; i++) {
            if SingleClassList[i].lecture === lecture {
                SingleClassList.removeAtIndex(i)
                i--
            }
        }
        for (var i=0; i<CourseList.count; i++) {
            if CourseList[i] === lecture {
                CourseList.removeAtIndex(i)
                break
            }
        }
        collectionView?.reloadData()
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
            cell.setColor()
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
