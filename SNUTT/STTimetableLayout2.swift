//
//  STTimetableLayout2.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 2..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STTimetableLayout2: UICollectionViewLayout {

    let delegate : STTimetableLayoutDelegate

    init(delegate: STTimetableLayoutDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else {
            return UICollectionViewLayoutAttributes(forCellWith: indexPath)
        }
        return delegate.layoutAttributesForItem(collectionView, at: indexPath)
    }

    override var collectionViewContentSize : CGSize {
        return CGSize(
            width: self.collectionView?.frame.size.width ?? 0,
            height: self.collectionView?.frame.size.height ?? 0
        )
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return []
        }
        var ret : [UICollectionViewLayoutAttributes] = []
//        for i in 0..<(collectionView.numberOfSections(in: collectionView)) {
//            for j in 0..<(collectionView.collectionView(collectionView, numberOfItemsInSection: i)) {
//                let indexPath = IndexPath(row: j, section: i)
//                ret.append(self.layoutAttributesForItem(at: indexPath))
//            }
//        }
        return ret
    }
}

protocol STTimetableLayoutDelegate {
    func layoutAttributesForItem(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes
}
