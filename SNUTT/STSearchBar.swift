//
//  STSearchBar.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 1..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchBar: UISearchBar, UISearchBarDelegate{
    
    weak var searchController : STLectureSearchTableViewController!
    var queryString : String = ""
    
    var isEditingTag : Bool = false {
        didSet {
            // TODO: Check whether return key is changed in real iphone
            if isEditingTag {
                self.returnKeyType = .Done
                self.reloadInputViews()
                self.setImage(UIImage(named: "icon_tag_gray"), forSearchBarIcon: .Search, state: .Normal)
                searchController.searchToolbarView.setEditingTag(true)
            } else {
                self.returnKeyType = .Search
                self.reloadInputViews()
                self.setImage(nil, forSearchBarIcon: .Search, state: .Normal)
                searchController.searchToolbarView.setEditingTag(false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.keyboardType = .Default
        self.returnKeyType = .Search
        self.enablesReturnKeyAutomatically = false
        self.tintColor = UIColor.blackColor()
    }
    
    func disableEditingTag() {
        if (isEditingTag) {
            isEditingTag = false
            self.text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        }
    }
    
    func enableEditingTag() {
        if (!isEditingTag) {
            queryString = self.text!
            self.text = "";
            isEditingTag = true
            self.searchBar(self, textDidChange: self.text!)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if isEditingTag {
            isEditingTag = false
            self.text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        } else {
            searchController.searchBarCancelButtonClicked()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if isEditingTag {
            if text.containsString("#") {
                let replacement = text.stringByReplacingOccurrencesOfString("#", withString: "")
                self.text!.replaceRange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                self.searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        } else {
            if text == "#" {
                queryString = self.text!
                queryString.replaceRange(STUtil.getRangeFromNSRange(queryString, range: range), with: "")
                self.text = "";
                isEditingTag = true
                self.searchBar(self, textDidChange: self.text!)
                return false
            } else if text.containsString("#") {
                let replacement = text.stringByReplacingOccurrencesOfString("#", withString: "")
                self.text!.replaceRange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                self.searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        }
    }
    
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchBar.isFirstResponder() {
            // this is only for the case of clicking clear button while not in focus
            searchController.state = .Empty
            return
        }
        
        if isEditingTag {
            searchController.showTagRecommendation()
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.showsCancelButton = true
        if case .Loaded(let query, let tagList) = searchController.state {
            searchController.state = .EditingQuery(query, tagList, searchController.FilteredList)
        } else {
             if case .Loading(let request) = searchController.state {
                request.cancel()
            }
            searchController.state = .EditingQuery(nil, [], [])
        }
        searchController.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.showsCancelButton = false
        searchController.reloadData()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if isEditingTag {
            if searchController.tagTableView.filteredList.count != 0 {
                searchController.tagTableView.addTagAtIndex(0)
            }
        } else {
            self.resignFirstResponder()
            searchController.searchBarSearchButtonClicked(self.text!)
        }
        
    }
    
}
