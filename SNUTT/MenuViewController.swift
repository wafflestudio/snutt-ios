//
//  MenuViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/03.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController {
    
    struct Section {
        var timetableList : [STTimetable]
        var courseBook : STCourseBook
    }
    
    var timetableList : [STTimetable] = []
    var sectionList : [Section] = []
    
    let currentTimetable = {
        return STTimetableManager.sharedInstance.currentTimetable
    }
    
    @IBOutlet weak var timetableListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.frame.size.width = UIScreen.main.bounds.size.width - 72
        
        timetableListTableView.delegate = self
        timetableListTableView.dataSource = self
        registerCellXib()
        registerHeaderView()
        
        STNetworking.getTimetableList({ list in
            self.timetableList = list
            self.reloadList()
        }, failure: {
            // TODO: No network status handling
            self.dismiss(animated: true, completion: nil)
        })
        
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CourseBookUpdated, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableSwitched, object: nil)
        reloadList()
    }
    
    var semesterList: [String]  {
        return self.sectionList.map({section in
            return section.courseBook.quarter.longString()
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
                                    }), courseBook: courseBook)
        })
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentTT = currentTimetable() {
            return currentTT.lectureList.count
            
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timetableListTableView.dequeueReusableCell(withIdentifier: "menuTableViewCell", for: indexPath)
        if let customCell = cell as? MenuTableViewCell, let currentTT = currentTimetable() {
            let title = currentTT.lectureList[indexPath.row].title
            customCell.setLabel(text: title)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = timetableListTableView.dequeueReusableHeaderFooterView(withIdentifier: "MenuTableViewHeaderView") as? MenuTableViewHeaderView, let currentTT = currentTimetable()
        else { return nil }
        view.delegate = self
        view.setHeaderLabel(text: currentTT.quarter.longString())
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    private func registerCellXib() {
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        timetableListTableView.register(nib, forCellReuseIdentifier: "menuTableViewCell")
    }
    
    private func registerHeaderView() {
        let nib = UINib(nibName: "MenuTableViewHeaderView", bundle: nil)
        timetableListTableView.register(nib, forHeaderFooterViewReuseIdentifier: "MenuTableViewHeaderView")
    }
}

extension MenuViewController: MenuTableViewHeaderViewDelegate {
    func presentSemesterPickView(_: MenuTableViewHeaderView) {
        let pickerViewController = TimetablePickerViewController(nibName: "TimetablePickerViewController", bundle: nil)
        pickerViewController.setSemesterList(list: semesterList)
        pickerViewController.modalPresentationStyle = .formSheet
        
        present(pickerViewController, animated: true)
    }
}
