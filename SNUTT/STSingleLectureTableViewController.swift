//
//  STSingleLectureTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 23..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework
import SafariServices

class STSingleLectureTableViewController: UITableViewController {

    var custom : Bool = false
    var currentLecture : STLecture = STLecture()
    
    enum CellViewType {
        case leftAligned(title : String)
        case colorPick
        case singleLabeled(title : String)
        case doubleLabeled(firstTitle: String, secondTitle: String)
        case padding
        case singleClass
        case textView(title: String)
        case button(title: String, color : UIColor)
        
        var identifier : String {
            switch self {
            case .leftAligned: return "LeftAlignedCell"
            case .colorPick: return "ColorPickCell"
            case .singleLabeled: return "SingleLabeledCell"
            case .doubleLabeled: return "DoubleLabeledCell"
            case .padding: return "PaddingCell"
            case .singleClass: return "SingleClassCell"
            case .textView: return "TextViewCell"
            case .button: return "ButtonCell"
            }
        }
    }
    
    enum CellType {
        case title
        case instructor
        case color
        case credit
        case department
        case academicYearAndCredit
        case classificationAndCategory
        case courseNumAndLectureNum
        case remark
        case singleClass
        case padding
        case addButton(section : Int)
        case resetButton
        case syllabusButton
        case deleteButton

        var cellViewType : CellViewType {
            switch self {
            case .title: return .leftAligned(title: "lecture_title".localizedString())
            case .instructor: return .leftAligned(title: "instructor".localizedString())
            case .color: return .colorPick
            case .credit: return .leftAligned(title: "credit".localizedString())
            case .department: return .singleLabeled(title: "department".localizedString())
            case .academicYearAndCredit:
                return .doubleLabeled(firstTitle: "academic_year".localizedString(), secondTitle: "credit".localizedString())
            case .classificationAndCategory:
                return .doubleLabeled(firstTitle: "classification".localizedString(), secondTitle: "category".localizedString())
            case .courseNumAndLectureNum:
                return .doubleLabeled(firstTitle: "course_number".localizedString(), secondTitle: "lecture_number".localizedString())
            case .remark:
                return .textView(title: "비고")
            case .singleClass:
                return .singleClass
            case .padding:
                return .padding
            case .addButton:
                return .button(title: "시간 추가", color: UIColor.black)
            case .resetButton:
                return .button(title: "초기화", color: UIColor.red)
            case .syllabusButton:
                return .button(title: "강의계획서", color: UIColor.black)
            case .deleteButton:
                return .button(title: "삭제", color: UIColor.red)
            }
        }
    }
    
    func cellTypeAtIndexPath(_ indexPath : IndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return .title
        case (0,1): return .instructor
        case (0,2): return .color
        case (0,3): return .credit
            
        case (1,0): return .padding
        case (1,1): return .department
        case (1,2): return .academicYearAndCredit
        case (1,3): return .classificationAndCategory
        case (1,4): return .courseNumAndLectureNum
        case (1,5): return .remark
        case (1,6): return .padding
            
        case (2,_): return .singleClass
        default: return .padding // Never Reach
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.register(UINib(nibName: "STSingleLabeledTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.singleLabeled(title: "").identifier)
        tableView.register(UINib(nibName: "STLeftAlignedTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.leftAligned(title: "").identifier)
        tableView.register(UINib(nibName: "STColorPickTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.colorPick.identifier)
        tableView.register(UINib(nibName: "STDoubleLabeledTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.doubleLabeled(firstTitle: "",secondTitle: "").identifier)
        tableView.register(UINib(nibName: "STSingleClassTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.singleClass.identifier)
        tableView.register(UINib(nibName: "STSingleLectureButtonCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.button(title: "", color: UIColor.black).identifier)
        tableView.register(UINib(nibName: "STTextViewTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.textView(title: "").identifier)
        tableView.register(STPaddingTableViewCell.self, forCellReuseIdentifier: CellViewType.padding.identifier)

        textviewCell = UINib(nibName: "STTextViewTableViewCell", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! STTextViewTableViewCell

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(STSingleLectureTableViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if custom {
            switch section {
            case 0: return 4
            case 1: return 0
            case 2: return currentLecture.classList.count
            default: return 0 // Never Reached
            }
        } else {
            switch section {
            case 0: return 3
            case 1: return 7
            case 2: return currentLecture.classList.count
            default: return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = cellTypeAtIndexPath(indexPath)
        let cellViewType = type.cellViewType
        let tmpCell = tableView.dequeueReusableCell(withIdentifier: cellViewType.identifier, for: indexPath)
        var doneBlock : ((String)->())?
        var timeDoneBlock : ((STTime)->())?
        var actionBlock : (()->())?
        var value1 : String = ""
        var value2 : String = ""
        switch type {
        case .academicYearAndCredit:
            value1 = currentLecture.academicYear ??  ""
            value2 = String(currentLecture.credit)
        case .classificationAndCategory:
            value1 = currentLecture.classification ?? ""
            value2 = currentLecture.category ?? ""
        case .color: break
        case .courseNumAndLectureNum:
            value1 = currentLecture.courseNumber ?? ""
            value2 = currentLecture.lectureNumber ?? ""
        case .credit:
            value1 = String(currentLecture.credit)
            doneBlock = { value in self.currentLecture.credit = Int(value) ?? 0}
        case .department:
            value1 = currentLecture.department ?? ""
        case .instructor:
            value1 = currentLecture.instructor
            doneBlock = { value in self.currentLecture.instructor = value }
        case .padding: break
        case .singleClass:
            doneBlock = { value in self.currentLecture.classList[indexPath.row].place = value }
            timeDoneBlock = { value in self.currentLecture.classList[indexPath.row].time = value }
        case .title:
            value1 = currentLecture.title
            doneBlock = { value in self.currentLecture.title = value }
        case .remark:
            value1 = currentLecture.remark ?? ""
            doneBlock = { value in self.currentLecture.remark = value }
        case let .addButton(section):
            actionBlock = { ()->() in
                self.currentLecture.classList.append(STSingleClass(time: STTime(day: 0, startPeriod: 0.0, duration: 1.0), place: ""))
                self.tableView.insertRows(at: [IndexPath(row: self.currentLecture.classList.count-1, section: section)], with: .automatic);
            }
        case .syllabusButton:
            actionBlock = { ()->() in
                let quarter = STTimetableManager.sharedInstance.currentTimetable!.quarter
                let lecture = self.currentLecture
                STNetworking.getSyllabus(quarter, lecture: lecture, done: { url in
                        self.showWebView(url)
                    }, failure: {
                        let year = quarter.year
                        let course_number = lecture.courseNumber!
                        let lecture_number = lecture.lectureNumber!
                        let semester = STTimetableManager.sharedInstance.currentTimetable!.quarter.semester;
                        var openShtmFg = "", openDetaShtmFg = ""
                        switch semester {
                        case .first:
                            openShtmFg = "U000200001";
                            openDetaShtmFg = "U000300001";
                        case .second:
                            openShtmFg = "U000200002";
                            openDetaShtmFg = "U000300001";
                        case .summer:
                            openShtmFg = "U000200001";
                            openDetaShtmFg = "U000300002";
                        case .winter:
                            openShtmFg = "U000200002";
                            openDetaShtmFg = "U000300002";
                        }
                        let url = "http://sugang.snu.ac.kr/sugang/cc/cc103.action?openSchyy=\(year)&openShtmFg=\(openShtmFg)&openDetaShtmFg=\(openDetaShtmFg)&sbjtCd=\(course_number)&ltNo=\(lecture_number)&sbjtSubhCd=000";
                        self.showWebView(url)
                })
            }
        case .resetButton:
            actionBlock = { ()->() in
                let actions = [
                    UIAlertAction(title: "초기화", style: .destructive, handler: { _ in
                        self.resetButtonClicked()
                    }),
                    UIAlertAction(title: "취소", style: .cancel, handler: nil)
                ]
                STAlertView.showAlert(title: "강좌 초기화", message: "강좌를 원래 상태로 초기화하시겠습니까?", actions: actions)
            }
        case .deleteButton:
            actionBlock = { ()->() in
                let actions = [
                    UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                        if let index = STTimetableManager.sharedInstance.currentTimetable?.lectureList.index(of: self.currentLecture) {
                            STTimetableManager.sharedInstance.deleteLectureAtIndex(index, object: nil)
                        }
                        self.navigationController?.popViewController(animated: true)
                    }),
                    UIAlertAction(title: "취소", style: .cancel, handler: nil)
                ]
                STAlertView.showAlert(title: "강좌 삭제", message: "강좌를 삭제하시겠습니까?", actions: actions)
            }
        }
        
        switch cellViewType {
        case .colorPick:
            let cell =  tmpCell as! STColorPickTableViewCell
            cell.color = currentLecture.color
            return cell
        case .padding:
            return tmpCell
        case .singleClass:
            let cell = tmpCell as! STSingleClassTableViewCell
            cell.singleClass = currentLecture.classList[indexPath.row]
            cell.placeDoneBlock = doneBlock
            cell.timeDoneBlock = timeDoneBlock
            cell.custom = true // Single Class Editable in non-custom
            return cell
        case let .leftAligned(title):
            let cell = tmpCell as! STLeftAlignedTableViewCell
            cell.titleLabel.text = title
            cell.textField.text = value1
            cell.doneBlock = doneBlock
            if case .credit = type {
                cell.textField.keyboardType = .numberPad
            } else {
                cell.textField.keyboardType = .default
            }
            return cell
        case let .singleLabeled(title):
            let cell = tmpCell as! STSingleLabeledTableViewCell
            cell.valueTextField.placeholder = title
            cell.valueTextField.text = value1
            return cell
        case let .doubleLabeled(firstTitle, secondTitle):
            let cell = tmpCell as! STDoubleLabeledTableViewCell
            cell.firstTextField.placeholder = firstTitle
            cell.secondTextField.placeholder = secondTitle
            cell.firstTextField.text = value1
            cell.secondTextField.text = value2
            return cell
        case let .textView(title):
            let cell = tmpCell as! STTextViewTableViewCell
            cell.doneBlock = doneBlock
            cell.textView.text = value1 == "" ? "(없음)" : value1
            cell.titleLabel.text = title
            cell.tableView = self.tableView
            return cell
        case let .button(title, color):
            let cell = tmpCell as! STSingleLectureButtonCell
            cell.buttonAction = actionBlock
            cell.button.tintColor = color
            cell.button.setTitle(title, for: UIControlState())
            cell.button.titleLabel?.text = title
            return cell
        }
    }

    var textviewCell : STTextViewTableViewCell!

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellTypeAtIndexPath(indexPath)
        if case CellType.remark = cellType {
            textviewCell.textView.text = currentLecture.remark == "" ? "(없음)" : currentLecture.remark
            return textviewCell.textView.sizeThatFits(CGSize(width: textviewCell.textView.frame.width, height: 300)).height + 30
        }
        switch cellType.cellViewType {
        case .leftAligned: return 36
        case .colorPick: return 36
        case .doubleLabeled, .singleLabeled: return 42
        case .padding: return 5
        case .singleClass: return 42
        case .button: return 36
        case .textView: return 75
        }
    }
    
    func triggerColorPicker() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "STColorPickerTableViewController") as! STColorPickerTableViewController
        viewController.color = currentLecture.color
        viewController.doneBlock = { color in
            self.currentLecture.color = color
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showWebView(_ url: String) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: URL(string: url)!)
            self.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    func resetButtonClicked() {
        return
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */


}
