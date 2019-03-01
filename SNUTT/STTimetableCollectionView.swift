//
//  STTimetableCollectionViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class STTimetableCollectionView: UICollectionView, UICollectionViewDataSource {

    var columnList = ["월", "화", "수", "목", "금", "토", "일"]
    var columnHidden = [false, false, false, false, false, false, false] {
        didSet {
            columnNum = columnHidden.filter({ hidden in return !hidden}).count
            var cnt = 0
            for (index, element) in columnHidden.enumerated() {
                if element {
                    dayToColumn[index] = -1
                    continue
                }
                dayToColumn[index] = cnt
                cnt += 1
            }
        }
    }
    var shouldAutofit : Bool = false
    
    fileprivate(set) var dayToColumn : [Int] = [0,1,2,3,4,5,6]
    fileprivate(set) var columnNum : Int = 7
    
    var rowStart : Int = 0
    var rowEnd : Int = STPeriod.periodNum - 1
    var rowNum : Int {
        get {
            return rowEnd - rowStart + 1
        }
    }
    func getRowFromPeriod(_ period : Double) -> Double {
        return period - Double(rowStart)
    }

    var cellLongClicked: ((STCourseCellCollectionViewCell)->())?
    var cellTapped: ((STCourseCellCollectionViewCell)->())?
    
    var showTemporary : Bool = false
    var timetable : STTimetable? = nil
    var tempLecture: STLecture? = nil
    var layout : STTimetableLayout! = nil
    
    let LectureSectionOffset = 3
    let RatioForHeader : CGFloat = 0.67
    let WidthForHeader : CGFloat = 25.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.register(UINib(nibName: "STCourseCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseCell")
        self.register(UINib(nibName: "STColumnHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColumnHeaderCell")
        self.register(UINib(nibName: "STRowHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RowHeaderCell")
        self.register(UINib(nibName: "STSlotCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SlotCell")

        self.backgroundColor = UIColor.white
        
        layout = STTimetableLayout()
        layout.WidthForHeader = WidthForHeader
        self.collectionViewLayout = layout
        (self.collectionViewLayout as! STTimetableLayout).timetableView = self

//        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<SectionType, CellData>>(configureCell: { (dataSource, collectionView, indexPath, data) -> UICollectionViewCell in
//            let collectionView = collectionView as! STTimetableCollectionView
//            switch data {
//            case .headerColumn(let columnName):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColumnHeaderCell", for: indexPath) as! STColumnHeaderCollectionViewCell
//                cell.contentLabel.text = columnName
//                return cell
//            case .headerRow(let rowName):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowHeaderCell", for: indexPath) as! STRowHeaderCollectionViewCell
//                cell.timeLabel.text = rowName
//                return cell
//            case let .slot(columnNum, rowNum, ratioForHeader, widthForHeader):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotCell", for: indexPath) as! STSlotCellCollectionViewCell
//                cell.columnNum = columnNum
//                cell.rowNum = rowNum
//                cell.ratioForHeader = ratioForHeader
//                cell.widthForHeader = widthForHeader
//                cell.setNeedsDisplay()
//                return cell
//            case .tempLecture(let lecture, let singleClass):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! STCourseCellCollectionViewCell
//                cell.setData(lecture: lecture, singleClass: singleClass)
//                cell.longClicked = collectionView.cellLongClicked
//                cell.tapped = collectionView.cellTapped
//                cell.layer.mask=nil
//                // TODO: move this logic to layout
//                if collectionView.dayToColumn[cell.singleClass.time.day.rawValue] == -1 {
//                    cell.isHidden = true
//                } else {
//                    cell.isHidden = false
////                    let heightPerRow = collectionView.frame.height / (CGFloat(rowNum) + RatioForHeader)
////                    if Double(rowStart) > cell.singleClass.time.startPeriod {
////                        cell.mask(CGRect(x: 0, y: heightPerRow * CGFloat(Double(rowStart) - cell.singleClass.time.startPeriod), width: cell.frame.width, height:cell.frame.height))
////                    }
//                }
//                return cell
//            case .lecture(let lecture, let singleClass):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! STCourseCellCollectionViewCell
//                cell.setData(lecture: lecture, singleClass: singleClass)
//                cell.longClicked = collectionView.cellLongClicked
//                cell.tapped = collectionView.cellTapped
//                cell.layer.mask=nil
//                if collectionView.dayToColumn[cell.singleClass.time.day.rawValue] == -1 {
//                    cell.isHidden = true
//                } else {
//                    cell.isHidden = false
////                    let heightPerRow = collectionView.frame.height / (CGFloat(rowNum) + RatioForHeader)
////                    if Double(rowStart) > cell.singleClass.time.startPeriod {
////                        cell.mask(CGRect(x: 0, y: heightPerRow * CGFloat(Double(rowStart) - cell.singleClass.time.startPeriod), width: cell.frame.width, height:cell.frame.height))
////                    }
//                }
//                return cell
//            }
//        })
//
//        let tmp2 : STTimetableDataSource<SectionModel<SectionType, CellData>>.LayoutAttributesForItem = { (dataSource, collectionView, indexPath, data) -> UICollectionViewLayoutAttributes in
//            let collectionView = collectionView as! STTimetableCollectionView
//            let collectionViewWidth = collectionView.frame.size.width
//            let collectionViewHeight = collectionView.frame.size.height
//            let widthPerColumn = (collectionViewWidth - collectionView.WidthForHeader) / CGFloat(collectionView.columnNum)
//            let heightPerRow = collectionViewHeight / (CGFloat(collectionView.rowNum) + collectionView.RatioForHeader)
//            let heightForHeader = collectionView.RatioForHeader * heightPerRow
//
//            var width : CGFloat
//            var height : CGFloat
//            var locX : CGFloat
//            var locY : CGFloat
//            var zIndex : Int
//            var isHidden = false
//            var maskY : CGFloat? = nil
//
//            switch data {
//            case .headerColumn:
//                width = widthPerColumn
//                height = heightForHeader
//                let columnIndex = collectionView.dayToColumn[indexPath.row]
//                locX = CGFloat(columnIndex) * widthPerColumn + collectionView.WidthForHeader
//                locY = CGFloat(0)
//                zIndex = 0
//            case .headerRow:
//                width = collectionView.WidthForHeader
//                height = heightPerRow
//                locX = CGFloat(0)
//                let rowIndex = CGFloat(collectionView.getRowFromPeriod(Double(indexPath.row)))
//                locY = heightForHeader + rowIndex * heightPerRow
//                zIndex = 3
//            case .slot:
//                width = collectionViewWidth
//                height = collectionViewHeight
//                locX = CGFloat(0)
//                locY = CGFloat(0)
//                zIndex = -1
//            case let .lecture(_, singleClass):
//                let rowIndex = CGFloat(collectionView.getRowFromPeriod(singleClass.time.startPeriod))
//                let columnIndex = collectionView.dayToColumn[singleClass.time.day.rawValue]
//                width = widthPerColumn
//                height = heightPerRow * CGFloat(singleClass.time.duration) + 0.4
//                locX = CGFloat(columnIndex) * widthPerColumn + collectionView.WidthForHeader
//                locY = heightForHeader + heightPerRow * rowIndex  - 0.2
//                if collectionView.dayToColumn[singleClass.time.day.rawValue] == -1 {
//                    isHidden = true
//                } else {
//                    if Double(collectionView.rowStart) > singleClass.time.startPeriod {
//                        maskY = heightPerRow * CGFloat(Double(collectionView.rowStart) - singleClass.time.startPeriod)
//                    }
//                }
//                zIndex = 1
//            case let .tempLecture(_, singleClass):
//                let rowIndex = CGFloat(collectionView.getRowFromPeriod(singleClass.time.startPeriod))
//                let columnIndex = collectionView.dayToColumn[singleClass.time.day.rawValue]
//                width = widthPerColumn
//                height = heightPerRow * CGFloat(singleClass.time.duration) + 0.4
//                locX = CGFloat(columnIndex) * widthPerColumn + collectionView.WidthForHeader
//                locY = heightForHeader + heightPerRow * rowIndex  - 0.2
//                zIndex = 1
//            }
//            let ret = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            ret.frame = CGRect(x: locX, y: locY, width: width, height: height)
//            ret.zIndex = zIndex
//            ret.isHidden = isHidden
//            if let maskY = maskY {
//                ret.mask = CGRect(x: 0, y: maskY, width: width, height: height - maskY)
//            }
//            return ret
//        }
//
        self.dataSource = self
        if (shouldAutofit) {
            autofit()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.dataSource = TimetableCollectionViewController.datasource
        //TimetableCollectionViewController.datasource.collectionView = self.collectionView
        // Do any additional setup after loading the view.
    }

    func autofit(includeTemp: Bool = false) {
        if timetable != nil && timetable?.lectureList.count != 0 {
            var tmpColumnHidden = [false,false,false,false,false,true,true]
            rowStart = 2
            rowEnd = 10
            
            for lecture in timetable!.lectureList {
                for singleClass in lecture.classList {
                    let startPeriod = Int(singleClass.time.startPeriod)
                    let endPeriod = Int(singleClass.time.endPeriod - 0.5)
                    rowStart = min(rowStart, startPeriod)
                    rowEnd = max(rowEnd, endPeriod)
                    let day = singleClass.time.day.rawValue
                    tmpColumnHidden[day] = false
                }
            }
            if let tempLecture = tempLecture, includeTemp {
                for singleClass in tempLecture.classList {
                    let startPeriod = Int(singleClass.time.startPeriod)
                    let endPeriod = Int(singleClass.time.endPeriod - 0.5)
                    rowStart = min(rowStart, startPeriod)
                    rowEnd = max(rowEnd, endPeriod)
                    let day = singleClass.time.day.rawValue
                    tmpColumnHidden[day] = false
                }
            }
            columnHidden = tmpColumnHidden;
            
        } else {
            columnHidden = [false,false,false,false,false,true,true]
            rowStart = 1
            rowEnd = 12
        }
        layout?.updateContentSize()
    }

    func getCellType(_ indexPath : IndexPath) -> STTimetableCellType {
        switch indexPath.section {
        case 0:
            return .slot
        case 1:
            return .headerColumn
        case 2:
            return .headerRow
        case (timetable?.lectureList.count)! + LectureSectionOffset:
            return .temporaryCourse
        default:
            return .course
        }
    }
    
    func getSingleClass(_ indexPath : IndexPath) -> STSingleClass {
        let lectureIndex = indexPath.section - LectureSectionOffset
        let classIndex = indexPath.row
        if lectureIndex == timetable!.lectureList.count {
            return tempLecture!.classList[classIndex]
        }
        return timetable!.lectureList[lectureIndex].classList[classIndex]
    }
    
    func getLecture(_ indexPath: IndexPath) -> STLecture {
        let lectureIndex = indexPath.section - LectureSectionOffset
        if lectureIndex == timetable!.lectureList.count {
            return tempLecture!
        }
        return timetable!.lectureList[lectureIndex]
    }
    
    func reloadTimetable(_ timetable: STTimetable?) {
        self.timetable = timetable
        if shouldAutofit {
            autofit()
        } else {
            layout?.updateContentSize()
        }
        
        self.reloadData()
    }

    private func reloadTempOnly() {
        UIView.performWithoutAnimation {
            reloadSections(IndexSet(integer: (timetable?.lectureList.count)! + LectureSectionOffset))
        }
    }
    
    func reloadTempLecture(_ tempLecture: STLecture?) {
        self.tempLecture = tempLecture
        // Assumption: autofit didn't change
        if !shouldAutofit {
            reloadTempOnly()
        }
        let oldCL = columnList
        let oldCH = columnHidden
        let oldRE = rowEnd
        let oldRS = rowStart
        autofit(includeTemp: true)
        if (columnList == oldCL && columnHidden == oldCH && rowEnd == oldRE && rowStart == oldRS) {
            reloadTempOnly()
        } else {
            UIView.performWithoutAnimation {
                self.performBatchUpdates({
                    //self.reloadItems(at: self.getAllIndexesForLecture())
                    self.reloadSections(IndexSet(integersIn: 0..<self.LectureSectionOffset))
                    self.reloadSections(IndexSet(integer: (self.timetable?.lectureList.count)! + self.LectureSectionOffset))
                }, completion: { _ in
                })
            }
            self.layout.invalidateLayout()
        }
    }

    func getAllIndexesForLecture() -> [IndexPath] {
        // Assumption: only used when there is temp
        var indices = [IndexPath]()
        let lectureCnt = (timetable?.lectureList.count)!
        for s in LectureSectionOffset...LectureSectionOffset+lectureCnt-1 {
            let rows = self.numberOfItems(inSection: s)
            if rows > 0{
                for r in 0...rows - 1{
                    let index = IndexPath(row: r, section: s)
                    indices.append(index)
                }
            }
        }
        return indices
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return columnList.count
        case 2:
            return STPeriod.periodNum
        default:
            let index = section - LectureSectionOffset
            if index < timetable!.lectureList.count{
                return timetable!.lectureList[index].classList.count
            } else if index == timetable!.lectureList.count, let tempLecture = tempLecture {
                return tempLecture.classList.count
            } else {
                return 0
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if timetable == nil {
            return LectureSectionOffset
        } else if showTemporary {
            return LectureSectionOffset + timetable!.lectureList.count + 1
        } else {
            return LectureSectionOffset + timetable!.lectureList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch getCellType(indexPath) {
        case .headerColumn:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColumnHeaderCell", for: indexPath) as! STColumnHeaderCollectionViewCell
            cell.isHidden = false
            cell.contentLabel.text = columnList[indexPath.row]
            if dayToColumn[indexPath.row] == -1 {
                cell.isHidden = true
            }
            return cell
        case .headerRow:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowHeaderCell", for: indexPath) as! STRowHeaderCollectionViewCell
            cell.isHidden = false
            cell.titleLabel.isHidden = true
            //cell.titleLabel.text = String(indexPath.row);
            cell.timeLabel.text = String(indexPath.row + 8)
            if !(rowStart <= indexPath.row && indexPath.row <= rowEnd) {
                cell.isHidden = true
            }
            return cell
        case .slot:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotCell", for: indexPath) as! STSlotCellCollectionViewCell
            cell.columnNum = columnNum
            cell.rowNum = rowNum
            cell.ratioForHeader = RatioForHeader
            cell.widthForHeader = WidthForHeader
            cell.setNeedsDisplay()
            return cell
        case .course:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! STCourseCellCollectionViewCell
            cell.isHidden = false
            cell.layer.mask=nil
            cell.setData(lecture: getLecture(indexPath), singleClass: getSingleClass(indexPath))
            cell.longClicked = cellLongClicked
            cell.tapped = cellTapped
            if dayToColumn[cell.singleClass.time.day.rawValue] == -1 {
                cell.isHidden = true
            }
            
            let heightPerRow = collectionView.frame.height / (CGFloat(rowNum) + RatioForHeader)
            if Double(rowStart) > cell.singleClass.time.startPeriod {
                cell.mask(CGRect(x: 0, y: heightPerRow * CGFloat(Double(rowStart) - cell.singleClass.time.startPeriod), width: cell.frame.width, height:cell.frame.height))
            }
            return cell
        case .temporaryCourse:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! STCourseCellCollectionViewCell
            cell.isHidden = false
            cell.layer.mask = nil
            cell.setData(lecture: getLecture(indexPath), singleClass: getSingleClass(indexPath))
            if dayToColumn[cell.singleClass.time.day.rawValue] == -1 {
                cell.isHidden = true
            }
            let heightPerRow = collectionView.frame.height / (CGFloat(rowNum) + RatioForHeader)
            if Double(rowStart) > cell.singleClass.time.startPeriod {
                cell.mask(CGRect(x: 0, y: heightPerRow * CGFloat(Double(rowStart) - cell.singleClass.time.startPeriod), width: cell.frame.width, height:cell.frame.height))
            }
            return cell
        }
    }
    
    // MARK: UICollectionViewSupplementary
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    enum SectionType {
        case headerColumn, headerRow, slot
        case tempLecture
        case lectureList
    }

    enum CellData {
        case headerColumn(columnName: String)
        case headerRow(rowName: String)
        case slot(columnNum: Int, rowNum: Int, ratioForHeader: CGFloat, widthForHeader: CGFloat)
        case tempLecture(lecture: STLecture, singleClass: STSingleClass)
        case lecture(lecture: STLecture, singleClass: STSingleClass)
    }
}
