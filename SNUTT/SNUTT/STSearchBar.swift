//
//  STSearchBar.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 1..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchBar: UISearchBar, UISearchBarDelegate {
    weak var searchController: STLectureSearchTableViewController!
    var queryString: String = ""

    var isEditingTag: Bool = false {
        didSet {
            if isEditingTag {
                returnKeyType = .done
                reloadInputViews()
                setImage(UIImage(named: "icon_tag_gray"), for: .search, state: UIControl.State())
            } else {
                returnKeyType = .search
                reloadInputViews()
                setImage(nil, for: .search, state: UIControl.State())
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        keyboardType = .default
        returnKeyType = .search
        enablesReturnKeyAutomatically = false
        tintColor = UIColor.black
    }

    func disableEditingTag() {
        if isEditingTag {
            isEditingTag = false
            text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        }
    }

    func enableEditingTag() {
        if !isEditingTag {
            queryString = text!
            text = ""
            isEditingTag = true
            searchBar(self, textDidChange: text!)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isEditingTag {
            isEditingTag = false
            text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        } else {
            searchController.searchBarCancelButtonClicked()
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isEditingTag {
            if text.contains("#") {
                let replacement = text.replacingOccurrences(of: "#", with: "")
                self.text!.replaceSubrange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        } else {
            if text == "#" {
                queryString = self.text!
                queryString.replaceSubrange(STUtil.getRangeFromNSRange(queryString, range: range), with: "")
                self.text = ""
                isEditingTag = true
                searchBar(self, textDidChange: self.text!)
                return false
            } else if text.contains("#") {
                let replacement = text.replacingOccurrences(of: "#", with: "")
                self.text!.replaceSubrange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange _: String) {
        if !searchBar.isFirstResponder {
            // this is only for the case of clicking clear button while not in focus
            // searchController.state = .empty
            return
        }
    }

    func searchBarTextDidBeginEditing(_: UISearchBar) {
        showsCancelButton = true
        if case let .loaded(query, tagList) = searchController.searchState {
            searchController.searchState = .editingQuery(query, tagList, searchController.FilteredList)
        } else {
            if case let .loading(request) = searchController.searchState {
                request.cancel()
            }
            searchController.searchState = .editingQuery(nil, [], [])
        }
        searchController.reloadData()
        searchController.tableView.reloadEmptyDataSet()

        if searchController.filterViewState == .opened {
            searchController.toggleFilterView()
        }
    }

    func searchBarTextDidEndEditing(_: UISearchBar) {
        showsCancelButton = false
        searchController.reloadData()
    }

    func searchBarSearchButtonClicked(_: UISearchBar) {
        if isEditingTag {
            if searchController.tagTableView.filteredList.count != 0 {
                searchController.tagTableView.addTagAtIndex(0)
            }
        } else {
            resignFirstResponder()
            searchController.searchBarSearchButtonClicked(text!)
        }
    }

    func searchBarBookmarkButtonClicked(_: UISearchBar) {
        searchController.toggleFilterView()
    }
}
