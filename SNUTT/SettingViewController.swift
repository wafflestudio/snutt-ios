//
//  SettingViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/10.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol SettingViewControllerDelegate: class {
    func renameTimetable(_: SettingViewController, _ timetable: STTimetable, title: String)
    func deleteTimetable(_: SettingViewController, _ timetable: STTimetable)
}

class SettingViewController: UIViewController {
    weak var delegate: SettingViewControllerDelegate?
    
    var timetable: STTimetable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func remove(_ sender: UIButton) {
        guard let timetable = self.timetable else { return }
        let alert = UIAlertController(title: "\"\(timetable.title)\" 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "네", style: .default) { _ in
            guard let timetable = self.timetable else { return }
            self.delegate?.deleteTimetable(self, timetable)
            self.dismiss(animated: true)
        }
        
        let cancel = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @IBAction func rename(_ sender: UIButton) {
        showRenameTextfield()
    }
    
    private func showRenameTextfield() {
        let alert = UIAlertController(title: "시간표 이름", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.minimumFontSize = 21
            textfield.placeholder = self.timetable?.title
            textfield.textAlignment = .center
        }
        
        let create = UIAlertAction(title: "바꾸기", style: .default) { action in
            guard let text = alert.textFields?[0].text, let timetable = self.timetable else { return }
            self.delegate?.renameTimetable(self, timetable, title: text)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(create)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
