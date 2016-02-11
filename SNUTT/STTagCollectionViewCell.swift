//
//  STTagCollectionViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    weak var collectionView : STTagCollectionView!
    var searchTag : String! {
        didSet {
            tagLabel.text = searchTag
        }
    }
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        let indexPath = self.collectionView.indexPathForCell(self)!
        collectionView.tagList.removeAtIndex(indexPath.row)
        collectionView.deleteItemsAtIndexPaths([indexPath])
        collectionView.setHidden()
    }
}
