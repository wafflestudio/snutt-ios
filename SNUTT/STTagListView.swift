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
    
    var filteredList : [STTag] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        self.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func adjustHeight () {
        heightConstraint.constant = self.contentSize.height + 10
    }
    
    func showTagsFor(_ query : String, type: STTagType?) {
        guard let tagList = STTagManager.sharedInstance.tagList else { return }
        if query == "" {
            filteredList = tagList.tagList
        } else {
            filteredList = tagList.tagList.filter{ tag in
                return tag.text.hasPrefix(query)
            }
        }
        if let tagType = type {
            filteredList = filteredList.filter{ tag in tag.type == tagType }
        }
        self.isHidden = false
        self.reloadData()
        adjustHeight()
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTagTableViewCell", for: indexPath) as! STTagTableViewCell
        let whiteAttribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white]
        let colorAttribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): filteredList[indexPath.row].type.tagColor]
        let text = NSMutableAttributedString()
        let sharpText = NSAttributedString(string: "# ", attributes: convertToOptionalNSAttributedStringKeyDictionary(colorAttribute))
        let tagText = NSAttributedString(string: filteredList[indexPath.row].text, attributes: convertToOptionalNSAttributedStringKeyDictionary(whiteAttribute))
        text.append(sharpText)
        text.append(tagText)
        cell.tagLabel.attributedText = text
        return cell
    }
    
    func addTagAtIndex(_ index: Int) {
        let tag = filteredList[index]
        searchController.addTag(tag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        addTagAtIndex(indexPath.row)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
