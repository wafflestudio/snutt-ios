//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableTabViewController: UIViewController {
    
    var timetableViewController : STTimetableCollectionViewController!
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
        
        timetableViewController = STTimetableCollectionViewController(collectionViewLayout: STTimetableLayout())
        timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        
        lectureListController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MyLectureListController") as! STMyLectureListController
        lectureListController.view.frame = containerView.frame
        settingChanged()
        
        self.addChildViewController(timetableViewController)
        timetableViewController.view.frame = containerView.frame
        containerView.addSubview(timetableViewController.view)
        timetableViewController.didMoveToParentViewController(self)
        
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
        
        timetableViewController?.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableViewController?.reloadTimetable()
    }
    
    func settingChanged() {
        if STDefaults[.autoFit] {
            timetableViewController?.shouldAutofit = true
        } else {
            timetableViewController?.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableViewController?.columnHidden = columnHidden
            timetableViewController?.rowStart = Int(STDefaults[.timeRange][0])
            timetableViewController?.rowEnd = Int(STDefaults[.timeRange][1])
        }
        timetableViewController?.reloadTimetable()
    }
    
    func switchView() {
        if (isInAnimation) {
            return
        }
        isInAnimation = true
        var oldVc, newVc : UIViewController!
        switch state {
        case .Timetable:
            oldVc = timetableViewController
            newVc = lectureListController
        case .LectureList:
            oldVc = lectureListController
            newVc = timetableViewController
        }
        oldVc.willMoveToParentViewController(nil)
        self.addChildViewController(newVc)
        
        UIView.animateWithDuration(1.0, animations: {
            switch self.state {
            case .LectureList:
                self.navigationItem.leftBarButtonItem!.image = UIImage(named:"navigationbaritem_list")
            case .Timetable:
                self.navigationItem.leftBarButtonItem!.image = UIImage(named:"navigationbaritem_timetable")
            }
        })
        
        self.transitionFromViewController(oldVc, toViewController: newVc, duration: 1.0, options: .TransitionFlipFromRight, animations: {
                self.containerView.addSubview(newVc.view)
                newVc.view.frame = self.containerView.frame
                oldVc.view.removeFromSuperview()
            }, completion: { finished in
                self.state = (self.state == .Timetable) ? .LectureList : .Timetable
                oldVc.removeFromParentViewController()
                newVc.didMoveToParentViewController(self)
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
}
