//
//  STTimetableDataSource.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 2..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class STTimetableDataSource<S: SectionModelType>:
    RxCollectionViewSectionedReloadDataSource<S>, STTimetableLayoutDelegate {

    public typealias LayoutAttributesForItem = (CollectionViewSectionedDataSource<S>, UICollectionView, IndexPath, I) -> UICollectionViewLayoutAttributes

    var layoutAttributesForItem: LayoutAttributesForItem

    public init(
        configureCell: @escaping ConfigureCell,
        layoutAttributesForItem: @escaping LayoutAttributesForItem
        ) {
        self.layoutAttributesForItem = layoutAttributesForItem
        super.init(configureCell: configureCell)
    }

    func layoutAttributesForItem(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        return self.layoutAttributesForItem(self, collectionView, indexPath, self[indexPath])
    }
}
