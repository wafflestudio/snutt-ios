//
//  STTagListView.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 1..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagListView: UITableView, UITableViewDelegate, UITableViewDataSource {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    weak var searchController : STLectureSearchTableViewController!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var tagList = ["컴공", "컴강", "컴곱", "캄가", "컫당", "갉", "갈", "마", "마", "마", "마","마","마"]
    
    var filteredList : [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        
    }
    
    func adjustHeight () {
        print(self.contentSize.height)
        heightConstraint.constant = self.contentSize.height + 10
    }
    
    func showTagsFor(query : String) {
        if query == "" {
            filteredList = tagList
        } else {
            filteredList = tagList.filter{ str in
                return str.hasPrefix(query)
            }
        }
        self.hidden = false
        self.reloadData()
        adjustHeight()
    }
    
    func hide() {
        self.hidden = true
    }
    
    func show() {
        self.hidden = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return filteredList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STTagTableViewCell", forIndexPath: indexPath)
        cell.textLabel!.text = "#" + filteredList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let tag = filteredList[indexPath.row]
        searchController.addTag(tag)
    }

}
