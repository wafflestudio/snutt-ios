//
//  SearchFilterViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/20.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol SearchFilterViewControllerDelegate: class {
    func hide(_: SearchFilterViewController)
    func addDetailTag(_: SearchFilterViewController, tag: STTag)
    func removeDetailTag(_: SearchFilterViewController, tag: STTag)
    func search(_: SearchFilterViewController)
}

class SearchFilterViewController: UIViewController {
    
    var delegate: SearchFilterViewControllerDelegate?
    var tagTypeList: [STTagType] = []
    var currentTagType: STTagType?
    var currentDetailTagList: [STTag] = []
    
    var tagDetailList: [STTag] {
        let tagList = STTagManager.sharedInstance.tagList.tagList
        let filteredTagList = tagList.filter { tag in tag.type == currentTagType }
        return filteredTagList
    }
    
    
    @IBOutlet weak var tagTypeListTableView: UITableView!
    @IBOutlet weak var tagDetailListTableView: UITableView!
    
    @IBAction func hide(_ sender: UIButton) {
        delegate?.hide(self)
    }
    
    @IBAction func applyFilter(_ sender: UIButton) {
        delegate?.search(self)
        delegate?.hide(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTypeList = [.AcademicYear, .Classification, .Credit, .Department, .Category]
        currentTagType = tagTypeList[0]
        
        tagTypeListTableView.delegate = self
        tagDetailListTableView.delegate = self
        tagTypeListTableView.dataSource = self
        tagDetailListTableView.dataSource = self
        
        registerCellXib()
    }
}

extension SearchFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagTypeListTableView {
            return tagTypeList.count
        }
        
        if tableView == tagDetailListTableView {
            return tagDetailList.count
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tagTypeListTableView {
            return 1
        }
        
        if tableView == tagDetailListTableView {
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tagTypeListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagTypeTableViewCell", for: indexPath)
            
            if let customCell = cell as? TagTypeTableViewCell {
                customCell.setLabel(text: tagTypeList[indexPath.row].typeStr)
                customCell.selectionStyle = .none
                customCell.unCheckLabel()
                
                if currentTagType == tagTypeList[indexPath.row] {
                    customCell.checkLabel()
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagDetailTableViewCell", for: indexPath)
            
            if let customCell = cell as? TagDetailTableViewCell {
                customCell.setLabel(text: tagDetailList[indexPath.row].text)
                customCell.selectionStyle = .none
                customCell.unCheck()
                
                if currentDetailTagList.contains(tagDetailList[indexPath.row]) {
                    customCell.check()
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tagTypeListTableView {
            return 52
        }
        
        if tableView == tagDetailListTableView {
            return 48
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tagTypeListTableView {
            currentTagType = tagTypeList[indexPath.row]
            tagTypeListTableView.reloadData()
            tagDetailListTableView.reloadData()
        }
        
        if tableView == tagDetailListTableView {
            let selectedTag = tagDetailList[indexPath.row]
            
            if !currentDetailTagList.contains(selectedTag) {
                currentDetailTagList.append(selectedTag)
                delegate?.addDetailTag(self, tag: selectedTag)
            } else {
                if let index = currentDetailTagList.index(of: selectedTag) {
                    currentDetailTagList.remove(at: index)
                    delegate?.removeDetailTag(self, tag: selectedTag)
                }
            }
            tagDetailListTableView.reloadData()
        }
    }
    
    private func registerCellXib() {
        let tagTypeNib = UINib(nibName: "TagTypeTableViewCell", bundle: nil)
        let tagDetailNib = UINib(nibName: "TagDetailTableViewCell", bundle: nil)
        tagTypeListTableView.register(tagTypeNib, forCellReuseIdentifier: "tagTypeTableViewCell")
        tagDetailListTableView.register(tagDetailNib, forCellReuseIdentifier: "tagDetailTableViewCell")
    }
    
    func reloadSelectedTagList() {
        tagTypeListTableView.reloadData()
        tagDetailListTableView.reloadData()
    }
}
