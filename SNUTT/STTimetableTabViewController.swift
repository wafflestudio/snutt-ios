//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableTabViewController: UIViewController {
    
    @IBOutlet weak var timetableView: STTimetableCollectionView!
    var lectureListController : STMyLectureListController!
    
    enum State {
    case timetable
    case lectureList
    }
    
    var state : State = .timetable
    var isInAnimation : Bool = false

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        titleView.textAlignment = .center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: "titleWasTapped")
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        self.navigationItem.leftBarButtonItem!.action = #selector(self.switchView)
        
        lectureListController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyLectureListController") as! STMyLectureListController
        lectureListController.timetableTabViewController = self
        lectureListController.view.frame = self.containerView.frame
        self.containerView.addSubview(lectureListController.view)
        lectureListController.view.isHidden = true

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        settingChanged()

        timetableView.cellLongClicked = self.cellLongClicked
        timetableView.cellTapped = self.cellTapped

        let _ = STColorManager.sharedInstance

        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "settingChanged", event: STEvent.SettingChanged, object: nil)
        
        reloadData()
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        let titleView = (self.navigationItem.titleView as! UILabel)
        let attribute = [NSForegroundColorAttributeName : UIColor.darkGray,
                         NSFontAttributeName : UIFont.systemFont(ofSize: 15)]
        let totalCreditStr = NSAttributedString(string: " \(STTimetableManager.sharedInstance.currentTimetable?.totalCredit ?? 0)학점", attributes: attribute)
        let mutableStr = NSMutableAttributedString()
        mutableStr.append(NSAttributedString(string: STTimetableManager.sharedInstance.currentTimetable?.title ?? ""))
        mutableStr.append(totalCreditStr)
        titleView.attributedText = mutableStr
        titleView.invalidateIntrinsicContentSize()
        
        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.reloadTimetable()
    }
    
    func settingChanged() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableView.columnHidden = columnHidden
            timetableView.rowStart = Int(STDefaults[.timeRange][0])
            timetableView.rowEnd = Int(STDefaults[.timeRange][1])
        }
        timetableView.reloadTimetable()
    }
    
    func switchView() {

        if (isInAnimation) {
            return
        }
        isInAnimation = true
        var oldView, newView : UIView!
        switch state {
        case .timetable:
            oldView = timetableView
            newView = lectureListController.view
        case .lectureList:
            oldView = lectureListController.view
            newView = timetableView
        }

        UIView.animate(withDuration: 0.65, animations: {
            switch self.state {
            case .lectureList:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "topbarListview")
            case .timetable:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "group2Copy")
            }
        })

        UIView.transition(with: containerView, duration: 0.65, options: .transitionFlipFromRight, animations: {
                oldView.isHidden = true
                newView.isHidden = false
            }, completion: { finished in
                self.state = (self.state == .timetable) ? .lectureList : .timetable
                self.isInAnimation = false
        })
    }
    
    func titleWasTapped() {
        guard let currentTimetable = STTimetableManager.sharedInstance.currentTimetable else {
            return
        }
        guard let timetableId = currentTimetable.id else {
            return
        }
        
        STAlertView.showAlert(title: "시간표 이름 변경", message: "새로운 시간표 이름을 입력해주세요", configAlert: { alert in
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = "새로운 시간표 이름"
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "이름 변경", style: .default, handler: { _ in
                if let timetableName = alert.textFields?.first?.text {
                    STNetworking.updateTimetable(timetableId, title: timetableName, done: {
                        STTimetableManager.sharedInstance.currentTimetable?.title = timetableName
                        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
                    })
                }
            }))
        })
    }

    func cellTapped(_ cell: STCourseCellCollectionViewCell) {
        let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = cell.lecture
        self.navigationController?.pushViewController(detailController, animated: true)

    }

    func cellLongClicked (_ cell : STCourseCellCollectionViewCell) {
        let oldColorIndex = cell.lecture.colorIndex;
        guard let collectionView = timetableView else {
            return
        }
        guard let indexPath = timetableView.indexPath(for: cell) else {
            return
        }
        let num = collectionView.numberOfItems(inSection: indexPath.section)
        let cellList : [STCourseCellCollectionViewCell?] = (0..<num).map { i in
            let tmpIndexPath = IndexPath(row: i, section: indexPath.section)
            return collectionView.cellForItem(at: tmpIndexPath) as? STCourseCellCollectionViewCell
        }
        var oldLecture = cell.lecture!
        STColorActionSheetPicker.showWithColor(oldColorIndex ?? 0, doneBlock: { selectedColorIndex in
            var newLecture = cell.lecture
            newLecture?.colorIndex = selectedColorIndex
            newLecture?.color = nil
            STTimetableManager.sharedInstance.updateLecture(
                oldLecture, newLecture: newLecture!, done: { _ in return }, failure: {
                    cellList.forEach { cell in
                        cell?.setColorByLecture(lecture: oldLecture)
                    }
            })
            }, cancelBlock: {
                cellList.forEach { cell in
                    cell?.setColorByLecture(lecture: oldLecture)
                }
            }, selectedBlock: { colorIndex in
                cellList.forEach { cell in
                    let color = STColorManager.sharedInstance.colorList.colorList[colorIndex-1]
                    cell?.setColor(color: color)
                }
            }, origin: self)
    }
}
