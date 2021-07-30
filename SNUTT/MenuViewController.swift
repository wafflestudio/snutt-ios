//
//  MenuViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/03.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import Foundation

protocol MenuViewControllerDelegate: class {
    func close(_: MenuViewController)
    func showThemeSettingView(_: MenuViewController, _ timetable: STTimetable )
}

class MenuViewController: UIViewController {
    
    struct Section {
        var timetableList : [STTimetable]
        var courseBook : STCourseBook
        var quarter: STQuarter
    }
    
    var timetableList : [STTimetable] = []
    var sectionList : [Section] = []
    var delegate: MenuViewControllerDelegate?
    var sheetAlert: UIAlertController?
    
    var currentTimetable: STTimetable? {
        return STTimetableManager.sharedInstance.currentTimetable
    }
    
    var currentQurterTimetableList: [STTimetable] {
        return currentSection[0].timetableList
    }
    
    var currentQuarter = STTimetableManager.sharedInstance.currentTimetable?.quarter
    
    var currentSection: [Section] {
        return sectionList.filter({ section in
            section.quarter == currentQuarter
        })
    }
    
    @IBOutlet weak var timetableListTableView: UITableView!
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.frame.size.width = UIScreen.main.bounds.size.width - 72
        
        timetableListTableView.delegate = self
        timetableListTableView.dataSource = self
        registerCellXib()
        registerHeaderView()
        
        fetchTablelist()
        
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CourseBookUpdated, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableSwitched, object: nil)
        reloadList()
    }
    
    private func fetchTablelist() {
        STNetworking.getTimetableList({ list in
            self.updateTableviewData(timetableList: list)
        }, failure: {
            // TODO: No network status handling
        })
    }
    
    private func updateTableviewData(timetableList: [STTimetable]) {
        self.timetableList = timetableList
        self.reloadList()
    }
    
    var semesterList: [STQuarter]  {
        return self.sectionList.map({section in
            return section.courseBook.quarter
        })
    }
    
    @objc func reloadList() {
        self.updateSectionedList()
        timetableListTableView.reloadData()
    }
    
    func updateSectionedList() {
        let courseBookList = STCourseBookList.sharedInstance.courseBookList
        sectionList = courseBookList.map({ courseBook in
            return Section.init(timetableList:
                                    timetableList.filter({ timetable in
                                        timetable.quarter == courseBook.quarter
                                    }), courseBook: courseBook, quarter: courseBook.quarter)
        })
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource, MenuTableViewHeaderViewDelegate {
    var cellLength: Int {
        return currentSection.count == 0 ? 0 : currentSection[0].timetableList.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLength
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timetableListTableView.dequeueReusableCell(withIdentifier: "menuTableViewCell", for: indexPath)
        guard cellLength > 0 else { return cell }
        
        if let customCell = cell as? MenuTableViewCell {
            customCell.delegate = self
            
            if indexPath.row == cellLength - 1 {
                customCell.setLabel(text: "+ 시간표 추가하기")
                customCell.setCreateNewCellStyle()
            } else {
                let timatable = currentQurterTimetableList[indexPath.row]
                customCell.timetable = timatable
                customCell.setDefaultCellStyle()
                customCell.setLabel(text: timatable.title)
                customCell.setCredit(credit: timatable.totalCredit)
                customCell.hideCheckIcon()
                
                if (timatable == currentTimetable) {
                    customCell.showCheckIcon()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = timetableListTableView.dequeueReusableHeaderFooterView(withIdentifier: "MenuTableViewHeaderView") as? MenuTableViewHeaderView, let quarter = currentQuarter
        else { return nil }
        view.delegate = self
        view.setHeaderLabel(text: quarter.longString())
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellLength - 1 {
            showCreateTextfield()
        } else {
            let selectedTimetable = currentQurterTimetableList[indexPath.row]
            guard let id = selectedTimetable.id else { return }
            
            STNetworking.getTimetable(id, done: { timetable in
                if (timetable == nil) {
                    STAlertView.showAlert(title: "시간표 로딩 실패", message: "선택한 시간표가 서버에 존재하지 않습니다.")
                }
                STTimetableManager.sharedInstance.currentTimetable = timetable
                self.fetchTablelist()
            }, failure: { _ in
                
            })
        }
    }
    
    private func registerCellXib() {
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        timetableListTableView.register(nib, forCellReuseIdentifier: "menuTableViewCell")
    }
    
    private func registerHeaderView() {
        let nib = UINib(nibName: "MenuTableViewHeaderView", bundle: nil)
        timetableListTableView.register(nib, forHeaderFooterViewReuseIdentifier: "MenuTableViewHeaderView")
    }
    
    private func showCreateTextfield() {
        let alert = UIAlertController(title: "시간표 이름", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.minimumFontSize = 21
            textfield.placeholder = "멋진 시간표"
        }
        
        let create = UIAlertAction(title: "만들기", style: .default) { action in
            guard let text = alert.textFields?[0].text else { return }
            
            self.addTimetable(text, courseBook: self.currentSection[0].courseBook)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(create)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension MenuViewController: TimetablePickerViewControllerDelegate {
    func presentSemesterPickView(_: MenuTableViewHeaderView) {
        let pickerViewController = TimetablePickerViewController(nibName: "TimetablePickerViewController", bundle: nil)
        pickerViewController.setSemesterList(list: semesterList)
        
        if let currentQuarter = currentTimetable?.quarter {
            pickerViewController.setSelectedSemester(index: semesterList.index(of: currentQuarter))
        } else {
            pickerViewController.setSelectedSemester(index: 0)
        }
        
        pickerViewController.delegate = self
        
        present(pickerViewController, animated: true)
    }
    
    func changeSemester(_ controller: TimetablePickerViewController, index: Int) {
        currentQuarter = sectionList[index].quarter
        self.timetableListTableView.reloadData()
    }
    
    private func addTimetable(_ title : String, courseBook : STCourseBook) {
        STNetworking.createTimetable(title, courseBook: courseBook, done: { list in
            self.timetableList = list
            self.reloadList()
        }, failure: {
            // TODO: 응답에 따른 에러 핸들링
            let alert = UIAlertController(title: "시간표 만들기 실패", message: "중복된 시간표 이름입니다", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
            
        })
    }
}

extension MenuViewController: MenuTableViewCellDelegate {
    func updateTableViewData(_ cell: MenuTableViewCell, timetableList: [STTimetable]) {
        updateTableviewData(timetableList: timetableList)
    }
    
    func showSettingSheet(_ cell: MenuTableViewCell) {
        let sheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "", style: .cancel)
        sheet.addAction(cancel)
        
        let settingController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        settingController.delegate = self
        settingController.timetable = cell.timetable
        settingController.settingSheet = sheet
        
        // Action Sheet를 커스터마이징하기 위한 트릭들
        guard let superview = view.superview?.superview?.superview?.superview else { return }
        
        superview.addSubview(sheet.view)
        
        sheet.view.frame = settingController.view.frame
        
        let screenWidth = UIScreen.main.bounds.size.width
        sheet.view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        sheet.view.widthAnchor.constraint(equalToConstant: screenWidth)
            .isActive = true
        sheet.view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        sheet.addChild(settingController)
        sheet.view.addSubview(settingController.view)
        
        present(sheet, animated: true)
    }
}

extension MenuViewController: SettingViewControllerDelegate {
    func showChangeThemeView(_: SettingViewController, _ timetable: STTimetable) {
        guard let timetable = currentTimetable else { return }
        delegate?.close(self)
        delegate?.showThemeSettingView(self, timetable)
        
    }
    
    func renameTimetable(_: SettingViewController, _ timetable: STTimetable, title: String) {
        guard let id = timetable.id else {
            STAlertView.showAlert(title: "시간표 이름 수정 실패", message: "")
            return
        }
        
        STNetworking.updateTimetable(id, title: title, done: { timetableList in
            if self.currentTimetable?.id == timetable.id {
                let updatedTimetable = timetableList.filter({ tt in
                    return tt.id == timetable.id
                })
                
                STTimetableManager.sharedInstance.currentTimetable = updatedTimetable[0]
            }
            
            self.timetableList = timetableList
            self.reloadList()
        }, failure: { errorTitle in
            STAlertView.showAlert(title: errorTitle, message: "")
            return
        })
    }
    
    func deleteTimetable(_: SettingViewController, _ timetable: STTimetable) {
        guard let id = timetable.id else {
            STAlertView.showAlert(title: "시간표 삭제 실패", message: "")
            return
        }
        
        if timetable == currentTimetable {
            STAlertView.showAlert(title: "현재 시간표는 삭제할 수 없습니다 ", message: "")
            return
        }
        
        STNetworking.deleteTimetable(id) {
            if let deletedIndex = self.timetableList.index(of: timetable) {
                self.timetableList.remove(at: deletedIndex)
                self.reloadList()
            }
        } failure: {
            STAlertView.showAlert(title: "시간표 삭제 실패", message: "")
        }
    }
}
