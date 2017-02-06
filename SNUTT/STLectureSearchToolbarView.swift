//
//  STLectureSearchToolbarView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 4..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureSearchToolbarView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var searchTableViewController: STLectureSearchTableViewController!
    @IBOutlet weak var sharpButton: UIButton!
    
    @IBOutlet weak var emptyTimeButton: UIButton!
    @IBOutlet weak var tagFilterCollectionView: UICollectionView!
    var isEditingTag: Bool {
        return searchTableViewController.searchBar.isEditingTag
    }
    var isEmptyTime: Bool = false;
    var sizingCell : STTagFilterCollectionViewCell!
    
    var tagTypeList : [STTagType] = []
    var currentTagType: STTagType?
    
    override func awakeFromNib() {
        emptyTimeButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        tagFilterCollectionView.delegate = self
        tagFilterCollectionView.dataSource = self
        let nib = UINib(nibName: "STTagFilterCollectionViewCell", bundle: nil)
        tagFilterCollectionView.registerNib(nib, forCellWithReuseIdentifier: "STTagFilterCollectionViewCell")
        sizingCell = nib.instantiateWithOwner(self, options: nil)[0] as! STTagFilterCollectionViewCell
        tagTypeList = [.AcademicYear, .Category, .Classification, .Credit, .Department, .Instructor]
        
        sharpButton.addTarget(self, action: #selector(sharpButtonClicked), forControlEvents: .PrimaryActionTriggered)
        emptyTimeButton.addTarget(self, action: #selector(emptyTimeButtonClicked), forControlEvents: .PrimaryActionTriggered)
        
        setEditingTag(false)
        
    }
    
    func sharpButtonClicked(sender: AnyObject) {
        if isEditingTag {
            searchTableViewController.searchBar.disableEditingTag()
        } else {
            searchTableViewController.searchBar.enableEditingTag()
        }
    }
    func emptyTimeButtonClicked(sender: AnyObject) {
        isEmptyTime = !isEmptyTime
        if isEmptyTime {
            emptyTimeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        } else {
            emptyTimeButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
    }
    
    func setEditingTag(editingTag: Bool) {
        if editingTag {
            sharpButton.setImage(nil, forState: .Normal)
            sharpButton.setTitle("취소", forState: .Normal)
            emptyTimeButton.superview?.hidden = true
            tagFilterCollectionView.superview?.hidden = false
        } else {
            sharpButton.setImage(UIImage(named: "icon_tag_black"), forState: .Normal)
            sharpButton.setTitle(nil, forState: .Normal)
            emptyTimeButton.superview?.hidden = false
            tagFilterCollectionView.superview?.hidden = true
        }
    }
    
    //MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        sizingCell.tagType = tagTypeList[indexPath.row]
        return sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize, withHorizontalFittingPriority: Float(self.frame.width), verticalFittingPriority: 27)
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagTypeList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("STTagFilterCollectionViewCell", forIndexPath: indexPath) as! STTagFilterCollectionViewCell
        cell.tagType = tagTypeList[indexPath.row]
        cell.isSelectedTag = tagTypeList[indexPath.row] == currentTagType
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedTagType = tagTypeList[indexPath.row]
        let curTagRow = currentTagType == nil ? nil : tagTypeList.indexOf(currentTagType!)
        if selectedTagType == currentTagType {
            currentTagType = nil
        } else {
            currentTagType = selectedTagType
        }
        var reloadIndexPaths = [indexPath]
        if let row = curTagRow {
            if row != indexPath.row {
                reloadIndexPaths.append(NSIndexPath(forRow: row, inSection: 0))
            }
        }
        collectionView.reloadItemsAtIndexPaths(reloadIndexPaths)
        searchTableViewController.showTagRecommendation()
    }
}
