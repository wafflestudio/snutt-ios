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
    weak var collectionView : STTagCollectionView!
    var searchTag : STTag! {
        didSet {
            tagLabel.text = searchTag.text
            containerView.backgroundColor = getColorFromTag(searchTag)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Ended {
            deleteTag()
        }
    }
    
    func deleteTag() {
        let indexPath = self.collectionView.indexPathForCell(self)!
        collectionView.tagList.removeAtIndex(indexPath.row)
        collectionView.deleteItemsAtIndexPaths([indexPath])
        collectionView.setHidden()
        collectionView.searchController.searchBar.becomeFirstResponder()
    }
    
    func getColorFromTag(tag: STTag) -> UIColor {
        switch tag.type {
        case .AcademicYear: return UIColor.flatNavyBlueColor()
        case .Category: return UIColor.flatCoffeeColorDark()
        case .Classification: return UIColor.flatForestGreenColorDark()
        case .Credit: return UIColor.flatTealColor()
        case .Department: return UIColor.flatOrangeColorDark()
        case .Instructor: return UIColor.flatPurpleColorDark()
        }
    }
}
