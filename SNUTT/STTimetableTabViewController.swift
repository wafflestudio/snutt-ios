//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class STTimetableTabViewController: UIViewController {
    
    lazy var timetableView2 = STTimetableView()
    var lectureListController : STMyLectureListController!
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    let settingManager = AppContainer.resolver.resolve(STSettingManager.self)!
    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!

    let disposeBag = DisposeBag()

    enum State {
        case timetable
        case lectureList
    }
    
    var state : State = .timetable
    var isInAnimation : Bool = false

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(timetableView2)
        timetableView2.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        timetableManager.rx.currentTimetable
            .subscribe(onNext: { [weak self] timetable in
                guard let self = self else { return }
                self.timetableView2.setTimetable(timetable)
            }).disposed(by: disposeBag)

        settingManager.rx.fitMode
            .subscribe(onNext: {[weak self] fitMode in
                self?.timetableView2.setFitMode(fitMode)
            }).disposed(by: disposeBag)

        colorManager.rx.colorList
            .subscribe(onNext: {[weak self] colorList in
                self?.timetableView2.setColorList(colorList)
            }).disposed(by: disposeBag)

        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        titleView.textAlignment = .center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(STTimetableTabViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        self.navigationItem.leftBarButtonItem!.action = #selector(self.switchView)
        
        lectureListController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyLectureListController") as! STMyLectureListController
        lectureListController.timetableTabViewController = self
        lectureListController.view.frame = self.containerView.frame
        self.containerView.addSubview(lectureListController.view)
        lectureListController.view.isHidden = true
        // TODO: cell event handle
//        timetableView.cellLongClicked = self.cellLongClicked
//        timetableView.cellTapped = self.cellTapped

        timetableManager.rx.currentTimetable.subscribe(onNext: { [weak self] timetable in
            guard let self = self else { return }
            let titleView = (self.navigationItem.titleView as! UILabel)
            let attribute = [NSAttributedStringKey.foregroundColor : UIColor.darkGray,
                             NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
            let totalCreditStr = NSAttributedString(string: " \(timetable?.totalCredit ?? 0)학점", attributes: attribute)
            let mutableStr = NSMutableAttributedString()
            mutableStr.append(NSAttributedString(string: timetable?.title ?? ""))
            mutableStr.append(totalCreditStr)
            titleView.attributedText = mutableStr
            titleView.invalidateIntrinsicContentSize()
        }).disposed(by: disposeBag)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func switchView() {

        if (isInAnimation) {
            return
        }
        isInAnimation = true
        var oldView, newView : UIView!
        switch state {
        case .timetable:
            oldView = timetableView2
            newView = lectureListController.view
        case .lectureList:
            oldView = lectureListController.view
            newView = timetableView2
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
    
    @objc func titleWasTapped() {
        guard let currentTimetable = timetableManager.currentTimetable else {
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
            alert.addAction(UIAlertAction(title: "이름 변경", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if let timetableName = alert.textFields?.first?.text {
                    let timetableManager = self.timetableManager
                    timetableManager.updateTitle(title: timetableName)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                }
            }))
        })
    }

    func cellTapped(_ lecture: STLecture) {
        let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = lecture
        self.navigationController?.pushViewController(detailController, animated: true)

    }

//    func cellLongClicked (_ cell : STCourseCellCollectionViewCell) {
//        let oldColorIndex = cell.lecture.colorIndex;
//        guard let collectionView = timetableView else {
//            return
//        }
//        guard let indexPath = timetableView.indexPath(for: cell) else {
//            return
//        }
//        let num = collectionView.numberOfItems(inSection: indexPath.section)
//        let cellList : [STCourseCellCollectionViewCell?] = (0..<num).map { i in
//            let tmpIndexPath = IndexPath(row: i, section: indexPath.section)
//            return collectionView.cellForItem(at: tmpIndexPath) as? STCourseCellCollectionViewCell
//        }
//        var oldLecture = cell.lecture!
//        let timetableManager = self.timetableManager
//        let colorManager = self.colorManager
//        STColorActionSheetPicker.showWithColor(oldColorIndex ?? 0, doneBlock: { selectedColorIndex in
//            var newLecture = cell.lecture
//            newLecture?.colorIndex = selectedColorIndex
//            newLecture?.color = nil
//            timetableManager.updateLecture(
//                oldLecture, newLecture: newLecture!, done: {  return }, failure: {
//                    cellList.forEach { cell in
//                        cell?.setColorByLecture(lecture: oldLecture)
//                    }
//            })
//            }, cancelBlock: {
//                cellList.forEach { cell in
//                    cell?.setColorByLecture(lecture: oldLecture)
//                }
//            }, selectedBlock: { colorIndex in
//                cellList.forEach { cell in
//                    let color = colorManager.colorList.colorList[colorIndex-1]
//                    cell?.setColor(color: color)
//                }
//            }, origin: self)
//    }
}
