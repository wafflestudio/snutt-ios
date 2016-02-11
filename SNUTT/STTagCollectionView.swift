//
//  STTagCollectionView.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var tagList : [String] = [""]
    weak var searchController : STLectureSearchTableViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
    }
    
    func hide() {
        searchController.tagCollectionViewConstraint.priority = 800
        UIView.animateWithDuration(0.2, animations:{
            self.layoutIfNeeded()
            self.searchController.tagTableView.layoutIfNeeded()
        })
    }
    
    func show() {
        searchController.tagCollectionViewConstraint.priority = 700
        UIView.animateWithDuration(0.2, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func setHidden() {
        if tagList.count == 0 {
            hide()
        } else {
            show()
        }
    }
    
    override func reloadData() {
        setHidden()
        super.reloadData()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("STTagCollectionViewCell", forIndexPath: indexPath) as! STTagCollectionViewCell
        cell.layer.cornerRadius = cell.frame.height / 2.0
        cell.searchTag = tagList[indexPath.row]
        cell.collectionView = self
        return cell
    }

}
