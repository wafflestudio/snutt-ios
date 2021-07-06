//
//  MenuViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/03.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController {
    
    @IBOutlet weak var timetableListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.frame.size.width = UIScreen.main.bounds.size.width - 72
        
        timetableListTableView.delegate = self
        timetableListTableView.dataSource = self
        registerCellXib()
        registerHeaderCellXib()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timetableListTableView.dequeueReusableCell(withIdentifier: "menuTableViewCell", for: indexPath)
        if let customCell = cell as? MenuTableViewCell {
            customCell.setLabel(text: "야야야")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = timetableListTableView.dequeueReusableCell(withIdentifier: "menuHeaderTableViewCell") as! MenuHeaderTableViewCell
        
        cell.setHeaderLabel(text: "밥묵자")
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    private func registerCellXib() {
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        timetableListTableView.register(nib, forCellReuseIdentifier: "menuTableViewCell")
    }
    
    private func registerHeaderCellXib() {
        let nib = UINib(nibName: "MenuHeaderTableViewCell", bundle: nil)
        timetableListTableView.register(nib, forCellReuseIdentifier: "menuHeaderTableViewCell")
    }
}
