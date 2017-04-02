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
            containerView.backgroundColor = searchTag.type.tagColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            deleteTag()
        }
    }
    
    func deleteTag() {
        let indexPath = self.collectionView.indexPath(for: self)!
        collectionView.tagList.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        collectionView.setHidden()
        collectionView.searchController.searchBar.becomeFirstResponder()
    }
    
}
