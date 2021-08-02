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
    var menuController: MenuViewController!
    var themeSettingController: ThemeSettingViewController!
    let backgroundView = UIView()
    
    enum ContainerViewState {
        case timetable
        case lectureList
    }
    
    enum MenuControllerState {
        case opened
        case closed
    }
    
    enum ThemeSettingViewState {
        case opened
        case closed
    }
    
    var originalTheme: STTheme?
    var temporaryTheme: STTheme?
    
    var containerViewState : ContainerViewState = .timetable
    var menuControllerState : MenuControllerState = .closed
    var themeSettingViewState : ThemeSettingViewState = .closed
    var isInAnimation : Bool = false
    
    @IBAction func captureTimeTable(_ sender: UIBarButtonItem) {
        showCaptureAlert()
    }
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var notiBarItem: UIBarButtonItem!
    
    @IBAction func switchToTimetableListView(_ sender: UIBarButtonItem) {
        switchView()
    }
    
    @IBOutlet var rightBarButtonsForTimetable: [UIBarButtonItem]!
    
    @IBAction func leftBarButtonItem(_ sender: UIBarButtonItem) {
        switch containerViewState {
        case .timetable:
            toggleMenuView()
        case .lectureList:
            switchView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.text = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center

        let leftItem = UIBarButtonItem(customView: titleView)
        self.navigationItem.leftBarButtonItems?.append(leftItem)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(STTimetableTabViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        
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
        
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.settingChanged), event: STEvent.SettingChanged, object: nil)
        
        reloadData()
        
        menuController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuController.delegate = self
        addMenuView()
        
        originalTheme = STTimetableManager.sharedInstance.currentTimetable?.theme
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNotiBadge(STDefaults[.shouldShowBadge])
        addThemeSettingView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeThemeSettingView()
    }
    
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadData() {
        if let titleView = self.navigationItem.leftBarButtonItems?.last?.customView as? UILabel {
            if let credit = STTimetableManager.sharedInstance.currentTimetable?.totalCredit, let title = STTimetableManager.sharedInstance.currentTimetable?.title {
                titleView.text = "\(title)"
            }
            
            titleView.sizeToFit();
        }
        
        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.reloadTimetable()
    }
    
    @objc func settingChanged() {
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
        switch containerViewState {
        case .timetable:
            oldView = timetableView
            newView = lectureListController.view
        case .lectureList:
            oldView = lectureListController.view
            newView = timetableView
        }
        
        UIView.animate(withDuration: 0.65, animations: {
            switch self.containerViewState {
            case .lectureList:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "topbarListview")
            case .timetable:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "btnLoginBack")
            }
        })
        
        UIView.transition(with: containerView, duration: 0.45, options: .curveEaseInOut, animations: {
            oldView.isHidden = true
            newView.isHidden = false
        }, completion: { finished in
            self.containerViewState = (self.containerViewState == .timetable) ? .lectureList : .timetable
            self.toggleBarItemsAccess(items: self.rightBarButtonsForTimetable)
            self.isInAnimation = false
            
        })
    }
    
    @objc func titleWasTapped() {
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
                    STNetworking.updateTimetable(timetableId, title: timetableName, done: {_ in 
                        STTimetableManager.sharedInstance.currentTimetable?.title = timetableName
                        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
                    }, failure: nil)
                }
            }))
        })
    }
    
    func cellTapped(_ cell: STCourseCellCollectionViewCell) {
        let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = cell.lecture
        detailController.theme = cell.theme
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
                oldLecture, newLecture: newLecture!, done: {  return }, failure: {
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
                //                    cell?.setColor(color: color)
            }
        }, origin: self)
    }
}

extension STTimetableTabViewController {
    func showCaptureAlert() {
        let image = captureTimetableView(of: self.view)
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func captureTimetableView(of view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: view.bounds.width,
                height: view.bounds.height
            ),
            false,
            2
        )
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return screenshot
    }
}

extension STTimetableTabViewController {
    private func toggleBarItemsAccess(items: [UIBarButtonItem]) {
        for item in items {
            switch containerViewState {
            case .timetable:
                item.tintColor = .black
                item.isEnabled = true
            case .lectureList:
                item.tintColor = .clear
                item.isEnabled = false
            }
        }
    }
}

// MARK: Menu view stuff
extension STTimetableTabViewController {
    private func addMenuView() {
        guard let menuVC = menuController else {
            return
        }
        self.tabBarController!.view.addSubview(backgroundView)
        self.tabBarController!.view.addSubview(menuVC.view)
        
        menuVC.view.frame.origin.x = -(menuVC.view.frame.width)
        
        menuVC.view.isHidden = true
        backgroundView.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:)))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureActionInMenuView(_:)))
        
        menuVC.view.addGestureRecognizer(panGestureRecognizer)
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        if (menuControllerState == .opened) {
            toggleMenuView()
        }
        if (themeSettingViewState == .opened) {
            toggleThemeSettingView()
        }
    }
    
    @objc private func didPanGestureActionInMenuView(_ sender: UIPanGestureRecognizer) {
        guard let menuView = menuController.view else { return }
        let translation = sender.translation(in: menuView)
        sender.setTranslation(CGPoint.zero, in: menuView)
        
        if sender.state == .changed {
            guard (menuView.frame.origin.x + translation.x) <= 0 else { return }
            
            menuView.frame.origin.x += translation.x
        }
        
        let currentOrigin = menuView.frame.origin.x
        let halfOfWidth = menuView.frame.width / 2
        
        if sender.state == .ended {
            if (sender.velocity(in: menuView).x < -550) {
                toggleMenuView()
            } else if (currentOrigin >= -(halfOfWidth)) {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                    self.menuController.view.frame.origin.x = 0
                }
            } else {
                toggleMenuView()
            }
        }
    }
    
    private func showBackgroundCoverView() {
        backgroundView.isHidden = false
        backgroundView.frame.size.width = self.containerView.frame.size.width
        backgroundView.frame.size.height = self.tabBarController!.view.frame.size.height
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    private func hideBackgroundCoverView() {
        if (themeSettingViewState == .opened) {
            STTimetableManager.sharedInstance.currentTimetable?.theme = originalTheme
            temporaryTheme = nil
            timetableView.reloadData()
        }
        backgroundView.frame.size.width = 0
        backgroundView.isHidden = true
    }
    
    private func toggleMenuView() {
        if (containerViewState == .lectureList) {
            return
        }
        
        switch menuControllerState {
        case .closed:
            showBackgroundCoverView()
            self.menuController.view.isHidden = false
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.menuController.view.frame.origin.x = 0
                
            } completion: { finished in
                self.menuControllerState = .opened
            }
            
        case .opened:
            self.hideBackgroundCoverView()
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                self.menuController.view.frame.origin.x = -(self.containerView.frame.width)
            } completion: { finished in
                self.menuController.view.isHidden = true
                self.menuControllerState = .closed
            }
        }
    }
}

extension STTimetableTabViewController {
    private func addThemeSettingView() {
        themeSettingController = ThemeSettingViewController(nibName: "ThemeSettingViewController", bundle: nil)
        //            themeSettingViewController?.delegate = self
        themeSettingController.setTemporaryTheme = setTemporaryTheme
        themeSettingController.setTheme = setTheme
        self.tabBarController!.view.addSubview(themeSettingController!.view)
        
        themeSettingController!.view.frame.size.width = self.tabBarController!.view.frame.width
        themeSettingController!.view.frame.origin.y = self.tabBarController!.view.frame.height
        themeSettingController!.view.layer.masksToBounds = true
        themeSettingController!.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func toggleThemeSettingView() {
        switch themeSettingViewState {
        case .closed:
            showBackgroundCoverView()
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.themeSettingController?.view.frame.origin.y = self.tabBarController!.view.frame.height - (self.themeSettingController?.view.frame.height ?? 0)
                
            } completion: { finished in
                self.themeSettingViewState = .opened
            }
            
        case .opened:
            hideBackgroundCoverView()
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                self.themeSettingController?.view.frame.origin.y = self.tabBarController!.view.frame.height
            } completion: { finished in
                self.themeSettingViewState = .closed
            }
        }
    }
}

// MARK: Set noti navbar item
extension STTimetableTabViewController {
    func setNotiBadge(_ shouldShowBadge: Bool) {
        if (shouldShowBadge) {
            notiBarItem.image = #imageLiteral(resourceName: "tabAlarmNotiOff").withRenderingMode(.alwaysOriginal)
        } else {
            notiBarItem.image = #imageLiteral(resourceName: "tabAlarmOff").withRenderingMode(.alwaysOriginal)
        }
        STDefaults[.shouldShowBadge] = shouldShowBadge
    }
}

extension STTimetableTabViewController: MenuViewControllerDelegate {
    
    func close(_: MenuViewController) {
        toggleMenuView()
    }
    
    func showThemeSettingView(_: MenuViewController, _ timetable: STTimetable) {
        toggleThemeSettingView()
    }
    
    private func setTemporaryTheme(_ theme: STTheme) {
        STTimetableManager.sharedInstance.currentTimetable?.theme = theme
        temporaryTheme = theme
        timetableView.reloadData()
    }
    
    private func setTheme() {
        if let timetable = STTimetableManager.sharedInstance.currentTimetable, let id = timetable.id {
            guard let theme = temporaryTheme else { return }
            STNetworking.updateTheme(id: id, theme: theme.rawValue) { (timetable) in
                self.originalTheme = self.temporaryTheme
                self.temporaryTheme = nil
                STTimetableManager.sharedInstance.currentTimetable = timetable
                self.toggleThemeSettingView()
                self.timetableView.reloadData()
            } failure: { (_) in
                
            }
        }
    }
    
    private func removeThemeSettingView() {
        self.themeSettingController!.view.removeFromSuperview()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
