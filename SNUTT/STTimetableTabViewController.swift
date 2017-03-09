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
    case Timetable
    case LectureList
    }
    
    var state : State = .Timetable
    var isInAnimation : Bool = false

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.text = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        titleView.textAlignment = .Center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: "titleWasTapped")
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        self.navigationItem.leftBarButtonItem!.action = #selector(self.switchView)
        
        lectureListController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MyLectureListController") as! STMyLectureListController
        lectureListController.view.frame = self.containerView.frame
        self.containerView.addSubview(lectureListController.view)
        lectureListController.view.hidden = true

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        settingChanged()

        timetableView.cellLongClicked = self.cellLongClicked
        timetableView.cellTapped = self.cellTapped
        
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadData", event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "settingChanged", event: STEvent.SettingChanged, object: nil)

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
        titleView.text = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        titleView.sizeToFit();
        
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
        case .Timetable:
            oldView = timetableView
            newView = lectureListController.view
        case .LectureList:
            oldView = lectureListController.view
            newView = timetableView
        }

        UIView.animateWithDuration(1.0, animations: {
            switch self.state {
            case .LectureList:
                self.navigationItem.leftBarButtonItem!.image = UIImage(named:"navigationbaritem_list")
            case .Timetable:
                self.navigationItem.leftBarButtonItem!.image = UIImage(named:"navigationbaritem_timetable")
            }
        })

        UIView.transitionWithView(containerView, duration: 1.0, options: .TransitionFlipFromRight, animations: {
                oldView.hidden = true
                newView.hidden = false
            }, completion: { finished in
                self.state = (self.state == .Timetable) ? .LectureList : .Timetable
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
            alert.addTextFieldWithConfigurationHandler({ textfield in
                textfield.placeholder = "새로운 시간표 이름"
            })
            alert.addAction(UIAlertAction(title: "취소", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "이름 변경", style: .Default, handler: { _ in
                if let timetableName = alert.textFields?.first?.text {
                    STNetworking.updateTimetable(timetableId, title: timetableName, done: {
                        STTimetableManager.sharedInstance.currentTimetable?.title = timetableName
                        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
                    })
                }
            }))
        })
    }

    func cellTapped(cell: STCourseCellCollectionViewCell) {
        let detailController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = cell.lecture
        self.navigationController?.pushViewController(detailController, animated: true)

    }

    func cellLongClicked (cell : STCourseCellCollectionViewCell) {
        let oldColor = cell.lecture.color
        guard let collectionView = timetableView else {
            return
        }
        guard let indexPath = timetableView.indexPathForCell(cell) else {
            return
        }
        let num = collectionView.numberOfItemsInSection(indexPath.section)
        let cellList : [STCourseCellCollectionViewCell?] = (0..<num).map { i in
            let tmpIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
            return collectionView.cellForItemAtIndexPath(tmpIndexPath) as? STCourseCellCollectionViewCell
        }
        STColorActionSheetPicker.showWithColor(cell.lecture.color, doneBlock: { selectedColor in
            var newLecture = cell.lecture
            newLecture.color = selectedColor
            var oldLecture = cell.lecture
            oldLecture.color = oldColor
            STTimetableManager.sharedInstance.updateLecture(
                oldLecture, newLecture: newLecture, failure: {
                    cellList.forEach { cell in
                        cell?.lecture.color = oldColor
                    }
            })
            }, cancelBlock: {
                cellList.forEach { cell in
                    cell?.lecture.color = oldColor
                }
            }, selectedBlock: { color in
                cellList.forEach { cell in
                    cell?.lecture.color = color
                }
            }, origin: self)
    }
}
