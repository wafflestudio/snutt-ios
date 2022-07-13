//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import LinkPresentation
import UIKit

class STTimetableTabViewController: UIViewController {
    @IBOutlet weak var timetableView: STTimetableCollectionView!
    var menuController: MenuViewController!
    var themeSettingController: ThemeSettingViewController!
    let backgroundView = UIView()
    var currentTimetable: STTimetable? {
        return STTimetableManager.sharedInstance.currentTimetable
    }
    var currentPopupList: [STPopup] {
        return STPopupManager.popupList
    }
    var currentPopup: STPopup?
    
    var shouldShowPopup: Bool = true

    enum PopupControllerState {
        case opened
        case closed
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

    var menuControllerState: MenuControllerState = .closed
    var themeSettingViewState: ThemeSettingViewState = .closed
    var popUpControllerState: PopupControllerState = .closed
    var isInAnimation: Bool = false

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var notiBarItem: UIBarButtonItem!

    @IBOutlet var rightBarButtonsForTimetable: [UIBarButtonItem]!

    @IBAction func leftBarButtonItem(_: UIBarButtonItem) {
        toggleMenuView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCurrentTimetable()

        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.text = currentTimetable?.title ?? ""
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let creditLabel = UILabel()
        creditLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        creditLabel.textColor = UIColor(hexString: "#B3B3B3")
        creditLabel.text = "(\(currentTimetable?.totalCredit ?? 0) 학점)"
        titleView.textAlignment = .center

        let leftTitleItem = UIBarButtonItem(customView: titleView)
        let leftCreditItem = UIBarButtonItem(customView: creditLabel)
        navigationItem.leftBarButtonItems?.append(leftTitleItem)
        navigationItem.leftBarButtonItems?.append(leftCreditItem)

        addRightBarButtons()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(STTimetableTabViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)

        navigationItem.leftBarButtonItem!.target = self

        timetableView.timetable = currentTimetable
        settingChanged()

        timetableView.cellLongClicked = cellLongClicked
        timetableView.cellTapped = cellTapped

        _ = STColorManager.sharedInstance

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.settingChanged), event: STEvent.SettingChanged, object: nil)

        reloadData()

        menuController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuController.delegate = self

        addMenuView()
        addThemeSettingView()
        
        tabBarController!.view.addSubview(backgroundView)
    }

    private func addRightBarButtons() {
        let imageList: [UIImage?] = [UIImage(named: "list"), UIImage(named: "share"), UIImage(named: "tabAlarmOff")]

        for (index, item) in rightBarButtonsForTimetable.enumerated() {
            let button = UIButton()
            button.setImage(imageList[index], for: .normal)
            button.frame.size = CGSize(width: 30, height: 30)

            switch index {
            case 0:
                button.addTarget(self, action: #selector(presentTimetableListView), for: .touchUpInside)
            case 1:
                button.addTarget(self, action: #selector(showCaptureAlert), for: .touchUpInside)
            case 2:
                button.addTarget(self, action: #selector(presentNotiView), for: .touchUpInside)
            default:
                return
            }
            item.customView = button
        }
    }

    @objc private func presentTimetableListView() {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyLectureListController") as? STMyLectureListController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func presentNotiView() {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotiListController") as? STNotificationTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewWillAppear(_: Bool) {
        setNotiBadge(STDefaults[.shouldShowBadge])
        if shouldShowPopup {
            loadPopUpView()
            shouldShowPopup = false
        }
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func reloadData() {
        guard let count = navigationItem.leftBarButtonItems?.count else {
            return
        }
        if let titleView = navigationItem.leftBarButtonItems?[count - 2].customView as? UILabel, let creditLabel = navigationItem.leftBarButtonItems?[count - 1].customView as? UILabel {
            if let credit = currentTimetable?.totalCreditByCal, let title = currentTimetable?.title {
                titleView.text = "\(title)"
                creditLabel.text = credit != 0 ? "(\(String(credit)) 학점)" : ""
            }

            titleView.sizeToFit()
        }

        timetableView.timetable = currentTimetable
        timetableView.reloadTimetable()
    }

    @objc func settingChanged() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden: [Bool] = []
            for i in 0 ... 6 {
                if dayRange[0] <= i, i <= dayRange[1] {
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

    @objc func titleWasTapped() {
        guard let currentTimetable = currentTimetable else {
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
                    STNetworking.updateTimetable(timetableId, title: timetableName, done: { _ in
                        currentTimetable.title = timetableName
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
        navigationController?.pushViewController(detailController, animated: true)
    }

    func cellLongClicked(_ cell: STCourseCellCollectionViewCell) {
        let oldColorIndex = cell.lecture.colorIndex
        guard let collectionView = timetableView else {
            return
        }
        guard let indexPath = timetableView.indexPath(for: cell) else {
            return
        }
        let num = collectionView.numberOfItems(inSection: indexPath.section)
        let cellList: [STCourseCellCollectionViewCell?] = (0 ..< num).map { i in
            let tmpIndexPath = IndexPath(row: i, section: indexPath.section)
            return collectionView.cellForItem(at: tmpIndexPath) as? STCourseCellCollectionViewCell
        }
        var oldLecture = cell.lecture!
        STColorActionSheetPicker.showWithColor(oldColorIndex ?? 0, doneBlock: { selectedColorIndex in
            var newLecture = cell.lecture
            newLecture?.colorIndex = selectedColorIndex
            newLecture?.color = nil
            STTimetableManager.sharedInstance.updateLecture(
                oldLecture, newLecture: newLecture!, done: {}, failure: {
                    cellList.forEach { cell in
                        cell?.setColorByLecture(lecture: oldLecture)
                    }
                }
            )
        }, cancelBlock: {
            cellList.forEach { cell in
                cell?.setColorByLecture(lecture: oldLecture)
            }
        }, selectedBlock: { colorIndex in
            cellList.forEach { _ in
                let color = STColorManager.sharedInstance.colorList.colorList[colorIndex - 1]
                //                    cell?.setColor(color: color)
            }
        }, origin: self)
    }
}

extension STTimetableTabViewController: UIActivityItemSource {
    @objc func showCaptureAlert() {
        let image = captureTimetableView(of: view)

        let activityVC = UIActivityViewController(activityItems: [self, image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view

        present(activityVC, animated: true, completion: nil)
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "SNUTT"
        return metadata
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
            item.tintColor = .black
            item.isEnabled = true
        }
    }
}

// MARK: Menu view stuff

extension STTimetableTabViewController {
    private func addMenuView() {
        guard let menuVC = menuController else {
            return
        }

        menuController.view.frame.origin.x = -(containerView.frame.width)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:)))

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureActionInMenuView(_:)))

        menuVC.view.addGestureRecognizer(panGestureRecognizer)
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func didTapBackgroundView(_: UITapGestureRecognizer) {
        if menuControllerState == .opened {
            toggleMenuView()
        }
        if themeSettingViewState == .opened {
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
            if sender.velocity(in: menuView).x < -550 {
                toggleMenuView()
            } else if currentOrigin >= -halfOfWidth {
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
        backgroundView.frame.size.width = containerView.frame.size.width
        backgroundView.frame.size.height = tabBarController!.view.frame.size.height
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    private func hideBackgroundCoverView() {
        if themeSettingViewState == .opened {
            currentTimetable?.theme = originalTheme
            temporaryTheme = nil
            timetableView.reloadData()
        }
        originalTheme = currentTimetable?.theme
        backgroundView.frame.size.width = 0
        backgroundView.isHidden = true
    }

    private func toggleMenuView() {
        guard let menuController = menuController else { return }
        switch menuControllerState {
        case .closed:
            showBackgroundCoverView()
            tabBarController!.view.addSubview(menuController.view)
            self.menuController?.fetchTablelist()
            self.menuController?.view.isHidden = false
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                menuController.view.frame.origin.x = 0

            } completion: { _ in
                self.menuControllerState = .opened
            }

        case .opened:
            hideBackgroundCoverView()
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                menuController.view.frame.origin.x = -(self.containerView.frame.width)
            } completion: { _ in
                menuController.view.isHidden = true
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

        let key = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        key?.addSubview(themeSettingController!.view)
        key?.bringSubviewToFront(themeSettingController!.view)

        themeSettingController!.view.frame.size.width = tabBarController!.view.frame.width
        themeSettingController!.view.frame.origin.y = tabBarController!.view.frame.height
        themeSettingController!.view.layer.masksToBounds = true
        themeSettingController!.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    func toggleThemeSettingView() {
        switch themeSettingViewState {
        case .closed:
            showBackgroundCoverView()
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.themeSettingController?.view.frame.origin.y = self.tabBarController!.view.frame.height - (self.themeSettingController?.view.frame.height ?? 0)
            } completion: { _ in
                self.themeSettingViewState = .opened
            }

        case .opened:
            hideBackgroundCoverView()
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                self.themeSettingController?.view.frame.origin.y = self.tabBarController!.view.frame.height
            } completion: { _ in
                self.themeSettingViewState = .closed
            }
        }
    }
}

// MARK: PopUp stuff

extension STTimetableTabViewController {
    private func becomeDelegate(of viewController: PopupViewController) {
        viewController.delegate = self
    }
    
    private func loadPopUpView() {
        print("currentPopupList: \(currentPopupList)")
        for popup in currentPopupList {
            let popUpViewController = PopupViewController()
            becomeDelegate(of: popUpViewController)
            popUpViewController.presentIfNeeded(popup: popup, at: popUpViewController)
            popUpViewController.popup = popup
            self.currentPopup = popup
            if currentPopupList.last != popup {
                popUpViewController.popupView.isHidden = true
            }
        }
    }
    
    private func changeBackgroundColor() {
        switch popUpControllerState {
        case .opened: showBackgroundCoverView()
        case .closed: hideBackgroundCoverView()
        }
    }
}

extension STTimetableTabViewController: PopupViewControllerDelegate {
    var rootVC: UIViewController? {
        UIApplication.shared.windows.first!.rootViewController
    }

    func present(viewController: PopupViewController) {
        popUpControllerState = .opened
        changeBackgroundColor()
        rootVC?.add(childVC: viewController)
    }
    
    /// 닫기
    func dismiss() {
        removePopup()
        if shouldClosePopupState() {
            popUpControllerState = .closed
        }
        changeBackgroundColor()
    }
    
    /// n일 동안 보지 않기
    func dismissForNdays() {
        removePopup()
        if shouldClosePopupState() {
            popUpControllerState = .closed
        }
        changeBackgroundColor()
        STPopupManager.saveLastUpdate(for: currentPopup)
    }
    
    /// 가장 상단의 팝업을 제거합니다.
    func removePopup() {
        guard let rootVC = rootVC else {
            return
        }
        let lastPopup = rootVC.children.last(where: { vc in
            vc.isKind(of: PopupViewController.self)
        })
        lastPopup?.remove(then: setNewCurrentPopup)
    }
    
    /// 모든 PopupViewController가 제거되었는지 확인합니다.
    func shouldClosePopupState() -> Bool {
        guard let rootVC = rootVC else {
            return true
        }
        if rootVC.children.first(where: { vc in
            vc.isKind(of: PopupViewController.self)
        }) == rootVC.children.last(where: { vc in
            vc.isKind(of: PopupViewController.self)
        }) {
            return true
        }
        return false
    }
    
    /// 새로운 currentPopup을 설정합니다.
    func setNewCurrentPopup() {
        guard let rootVC = rootVC else {
            return
        }
        let newLastPopup = rootVC.children.last(where: { vc in
            vc.isKind(of: PopupViewController.self)
        }) as? PopupViewController
        
        newLastPopup?.popupView.isHidden = false
        currentPopup = newLastPopup?.popup
    }
}

// MARK: Set noti navbar item

extension STTimetableTabViewController {
    func setNotiBadge(_ shouldShowBadge: Bool) {
        let notiButton = rightBarButtonsForTimetable.last?.customView as? UIButton

        if shouldShowBadge {
            let image = #imageLiteral(resourceName: "tabAlarmNotiOff").withRenderingMode(.alwaysOriginal)
            notiButton?.setImage(image, for: .normal)
        } else {
            let image = #imageLiteral(resourceName: "tabAlarmOff").withRenderingMode(.alwaysOriginal)
            notiButton?.setImage(image, for: .normal)
        }
        STDefaults[.shouldShowBadge] = shouldShowBadge
    }
}

extension STTimetableTabViewController: MenuViewControllerDelegate {
    func close(_: MenuViewController) {
        toggleMenuView()
    }

    func showThemeSettingView(_: MenuViewController, _: STTimetable) {
        toggleThemeSettingView()
    }

    private func setTemporaryTheme(_ theme: STTheme) {
        currentTimetable?.theme = theme
        temporaryTheme = theme
        timetableView.reloadData()
    }

    private func setTheme() {
        if let timetable = currentTimetable, let id = timetable.id {
            guard let theme = temporaryTheme else {
                return
            }
            STNetworking.updateTheme(id: id, theme: theme.rawValue) { timetable in
                self.originalTheme = self.temporaryTheme
                self.temporaryTheme = nil
                STTimetableManager.sharedInstance.currentTimetable = timetable
                self.toggleThemeSettingView()
                self.timetableView.reloadData()
            } failure: { _ in
            }
        }
    }
}

extension STTimetableTabViewController {
    private func fetchCurrentTimetable() {
        STNetworking.getRecentTimetable({ [weak self] timetable in
            STTimetableManager.sharedInstance.currentTimetable = timetable
        }, failure: {
            STAlertView.showAlert(title: "시간표 로딩 실패", message: "시간표가 서버에 존재하지 않습니다.")
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
