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
    weak var tagTableView : STTagListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: "textFieldDidEdit", forControlEvents: .EditingChanged)
    }
    
    func textFieldDidEdit() {
        let wordRange = self.getSelectedWordRange()
        if wordRange.length == 0 {
            tagTableView.hidden = true
            return
        }
        let word = NSString(string: textField.text!).substringWithRange(wordRange)
        if word.substringToIndex(word.startIndex.advancedBy(1)) == "#" {
            let query = word.substringFromIndex(word.startIndex.advancedBy(1))
            tagTableView.showTagsFor(query)
        } else {
            tagTableView.hidden = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tagTableView.hidden = true
    }
    
    func getSelectedRange() -> NSRange {
        let beginning = textField.beginningOfDocument
        
        if let selectedRange = textField.selectedTextRange {
            let selectionStart = selectedRange.start
            let selectionEnd = selectedRange.end
            
            let location = textField.offsetFromPosition(beginning, toPosition: selectionStart)
            let length = textField.offsetFromPosition(selectionStart, toPosition: selectionEnd)
            
            return NSMakeRange(location, length)
        } else {
            return NSMakeRange(0, 0)
        }
        
        
    }
    
    func getSelectedWordRange() -> NSRange {
        let text = NSString(string: textField.text!)
        let range = self.getSelectedRange()
        let location = range.location
        
        // Aborts in case minimum requieres are not fufilled
        if text.length == 0 || location < 0 || (range.location+range.length) > text.length {
            return NSMakeRange(0, 0)
        }
        
        let leftPortion = text.substringToIndex(location)
        let leftComponents = leftPortion.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let leftWordPart = leftComponents.last
        
        let rightPortion = text.substringFromIndex(location)
        let rightComponents = rightPortion.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let rightPart = rightComponents.first
        
        if location > 0 {
            let characterBeforeCursor = text.substringWithRange(NSRange(location: location-1, length: 1))
            
            if characterBeforeCursor == " " {
                return NSRange(location: location, length: rightPart!.characters.count)
            }
        }
        
        // In the middle of a word, so combine the part of the word before the cursor, and after the cursor to get the current word
        
        let rangePointer = NSRange(location: location-leftWordPart!.characters.count, length: leftWordPart!.characters.count + rightPart!.characters.count)
        
        return rangePointer
    }
    
}
