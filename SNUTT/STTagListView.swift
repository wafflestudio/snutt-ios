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
    
    weak var searchBar : STSearchBar!
    
    var tagList = ["컴공", "컴공학부", "화생공", "화생공공공공"]
    
    var filteredList : [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        
    }
    
    func showTagsFor(query : String) {
        print(query)
        filteredList = tagList.filter{ str in
            let prefix = str.commonPrefixWithString(query, options: .LiteralSearch)
            print(str + " : " + prefix)
            print(String(prefix.characters.count) + " : " + String(query.characters.count))
            return prefix.characters.count == query.characters.count
        }
        self.hidden = false
        self.reloadData()
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
        cell.textLabel!.text = filteredList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = filteredList[indexPath.row]
        searchBar.addTag(tag)
    }

}
