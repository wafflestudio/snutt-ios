//
//  ExpandableLectureListView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import SharedUIComponents
import SnapKit
import SwiftUI
import TimetableInterface
import UIKit

struct ExpandableLectureListView: UIViewControllerRepresentable {
    let viewModel: any ExpandableLectureListViewModel
    func makeUIViewController(context _: Context) -> some UIViewController {
        ExpandableLectureListViewController(viewModel: viewModel)
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

private final class ExpandableLectureListViewController: UIViewController {
    private let viewModel: any ExpandableLectureListViewModel
    init(viewModel: any ExpandableLectureListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false
    private lazy var dataSource = createDataSource()
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = ExpandableLectureCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .clear
        collectionView.prefetchDataSource = self
        collectionView.delaysContentTouches = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
    }

    private func applyDataSource(_ lectures: [any Lecture], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(lectures.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func reconfigureItem(_ lectures: [any Lecture]) {
        var snapshot = dataSource.snapshot()
        let lectureSet = Set(lectures.map { $0.id })
        snapshot.reconfigureItems(Array(lectureSet))
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func bindViewModel() {
        viewModel.lecturesPublisher
            .sink { [weak self] lectures in
                self?.applyDataSource(lectures)
            }
            .store(in: &cancellables)
    }

    private func fetchMoreLecturesIfNeeded() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            await viewModel.fetchMoreLectures()
            isLoading = false
        }
    }
}

extension ExpandableLectureListViewController {
    private typealias LectureID = String
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, LectureID>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, LectureID>
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<ExpandableLectureCell, LectureID> { [weak self] cell, indexPath, _ in
            guard let self else { return }
            let lecture = viewModel.lectures[indexPath.row]
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ExpandableLectureCell.ContentView(viewModel: viewModel as! LectureSearchViewModel, lecture: lecture)
            })
            .margins(.all, 0)
        }
        return DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
}

extension ExpandableLectureListViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            fetchMoreLecturesIfNeeded()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lecture = viewModel.lectures[indexPath.row]
        let isSelected = viewModel.isSelected(lecture: lecture)
        return .init(width: collectionView.bounds.width, height: isSelected ? 175 : 125)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lecture = viewModel.lectures[indexPath.row]
        viewModel.selectLecture(lecture)
        flowLayout.invalidateLayout()
        UIView.animateSpring {
            collectionView.layoutIfNeeded()
        }
    }
}

extension ExpandableLectureListViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        if indexPaths.contains(where: { $0.row == itemCount - 1 }) {
            fetchMoreLecturesIfNeeded()
        }
    }
}

private final class ExpandableLectureCollectionView: UICollectionView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            true
        } else {
            super.touchesShouldCancel(in: view)
        }
    }
}

@available(iOS 17, *)
#Preview {
    let viewModel = LectureSearchViewModel()
    _ = Task {
        await viewModel.fetchInitialSearchResult()
    }
    ZStack {
        TimetableAsset.searchlistBackground.swiftUIColor
        ExpandableLectureListView(viewModel: viewModel)
    }
}
