//
//  STSearchBar.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 1..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchBar: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var cancelButtonConstraint: NSLayoutConstraint!
    weak var searchController : STLectureSearchTableViewController!
    var queryString : String = ""
    
    private var isEditingTag : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: "textFieldDidEdit", forControlEvents: .EditingChanged)
        textField.keyboardType = .Twitter
    }
    
    func disableEditingTag() {
        isEditingTag = false
        textField.text = queryString
        queryString = ""
    }
    
    func showCancelButton() {
        cancelButtonConstraint.priority = UILayoutPriorityDefaultHigh
        self.layoutIfNeeded()
    }
    
    func hideCancelButton() {
        cancelButtonConstraint.priority = UILayoutPriorityDefaultLow
        self.layoutIfNeeded()
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        searchController.searchBarCancelButtonClicked()
        self.textField.resignFirstResponder()
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if isEditingTag {
            if string.containsString("#") {
                let replacement = string.stringByReplacingOccurrencesOfString("#", withString: "")
                textField.text!.replaceRange(STUtil.getRangeFromNSRange(textField.text!, range: range), with: replacement)
                textFieldDidEdit()
                return false
            }
            return true
        } else {
            if string == "#" {
                queryString = textField.text!
                queryString.replaceRange(STUtil.getRangeFromNSRange(queryString, range: range), with: "")
                textField.text = "#"
                textFieldDidEdit()
                return false
            } else if string.containsString("#") {
                let replacement = string.stringByReplacingOccurrencesOfString("#", withString: "")
                textField.text!.replaceRange(STUtil.getRangeFromNSRange(textField.text!, range: range), with: replacement)
                textFieldDidEdit()
                return false
            }
            return true
        }
    }
    
    func textFieldDidEdit() {
        
        if textField.text! == "" {
            isEditingTag = false
            textField.text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        } else if textField.text!.hasPrefix("#") {
            isEditingTag = true
        }
        
        if isEditingTag {
            let query = textField.text!.substringFromIndex(textField.text!.startIndex.advancedBy(1))
            searchController.showTagRecommendation(query)
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.showCancelButton()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.hideCancelButton()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        searchController.searchBarSearchButtonClicked(self.textField.text!)
        return true
    }
    
}
