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
            if (includeTemp && timetable!.temporaryLecture != nil) {
                for singleClass in timetable!.temporaryLecture!.classList {
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
            return timetable!.temporaryLecture!.classList[classIndex]
        }
        return timetable!.lectureList[lectureIndex].classList[classIndex]
    }
    
    func getLecture(_ indexPath: IndexPath) -> STLecture {
        let lectureIndex = indexPath.section - LectureSectionOffset
        if lectureIndex == timetable!.lectureList.count {
            return timetable!.temporaryLecture!
        }
        return timetable!.lectureList[lectureIndex]
    }
    
    func reloadTimetable() {
        
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
    
    func reloadTempLecture() {
        // Assumption: autofit didn't change
        if !shouldAutofit {
            reloadTempOnly()
        }
        let oldCL = columnList
        let oldCH = columnHidden
        let oldRE = rowEnd
        let oldRS = rowStart
        if STDefaults[.autoFit] {
            autofit(includeTemp: true)
        }
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
            } else if index == timetable!.lectureList.count && timetable!.temporaryLecture != nil {
                return timetable!.temporaryLecture!.classList.count
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
            
            let lecture = getLecture(indexPath)
            cell.longClicked = cellLongClicked
            cell.tapped = cellTapped
            cell.theme = timetable?.theme
            cell.setData(lecture: lecture, singleClass: getSingleClass(indexPath))
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
            
            // TODO: 임시 강의 색깔 정하는게 조금 부자연스러움
            cell.courseText.textColor = .black
            cell.backgroundColor = UIColor(red: 207, green: 207, blue: 207)
            
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

}
