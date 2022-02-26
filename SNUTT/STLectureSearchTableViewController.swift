//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Alamofire
import DZNEmptyDataSet
import UIKit

class STLectureSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet var searchBar: STSearchBar!

    @IBOutlet var tableView: UITableView!

    @IBOutlet var tagCollectionView: STTagCollectionView!
    @IBOutlet var tagTableView: STTagListView!

    @IBOutlet var tagCollectionViewConstraint: NSLayoutConstraint!

    @IBOutlet var timetableView: STTimetableCollectionView!
    var FilteredList: [STLecture] = []
    var pageNum: Int = 0
    var perPage: Int = 20
    var isLast: Bool = false

    enum SearchState {
        case empty
        case editingQuery(String?, [STTag], [STLecture])
        case loading(Request)
        case loaded(String, [STTag])
    }

    enum FilterViewState {
        case opened
        case closed
    }

    var searchState: SearchState = .empty
    var filterViewState: FilterViewState = .closed

    var filterViewController: SearchFilterViewController?

    var tagList: [STTag] {
        return tagCollectionView.tagList
    }

    var backgTapRecognizerWhenFilter: UITapGestureRecognizer?
    var backgTapRecognizer: UITapGestureRecognizer?
    var filterViewPanGestureRecognizer: UIPanGestureRecognizer?

    func reloadData() {
        tableView.reloadData()
        STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STLectureSearchTableViewController.timetableSwitched), event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STLectureSearchTableViewController.reloadTimetable), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STLectureSearchTableViewController.reloadTempLecture), event: STEvent.CurrentTemporaryLectureChanged, object: nil)

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        searchBar.searchController = self
        tagTableView.searchController = self
        tagCollectionView.searchController = self

        initEmptyDataSet()

        tableView.register(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")

        searchBar.showsBookmarkButton = true

        let filterImage = UIImage(named: "filter")
        searchBar.setImage(filterImage, for: .bookmark, state: .normal)
        searchBar.placeholder = "검색어를 입력하세요"

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.showTemporary = true
        settingChanged()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STLectureSearchTableViewController.settingChanged), event: STEvent.SettingChanged, object: nil)

        backgTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgView(_:)))
        backgTapRecognizer?.cancelsTouchesInView = false
        tableView.addGestureRecognizer(backgTapRecognizer!)

        backgTapRecognizerWhenFilter = UITapGestureRecognizer(target: self, action: #selector(didTapBackgViewWhenFilter(_:)))

        filterViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureActionInFilterView(_:)))
    }

    override func viewDidAppear(_: Bool) {
        addShowFilterView()
        reloadTempLecture()
    }

    override func viewDidDisappear(_: Bool) {
        removeShowFilterView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    @objc func settingChanged() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden: [Bool] = []
            for i in 0 ... 6 {
                if dayRange[0] <= i, i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableView.columnHidden = columnHidden
            timetableView.rowStart = Int(STDefaults[.timeRange][0])
            timetableView.rowEnd = Int(STDefaults[.timeRange][1])
        }
        timetableView.reloadTimetable()
    }

    func getLectureList(_ searchString: String) {
        // This is for saving the request
        isLast = false
        let emptyTag = tagList.filter { tag -> Bool in
            tag.text == EtcTag.empty.rawValue
        }

        let mask = emptyTag.count != 0 ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: 0, limit: perPage))
        searchState = .loading(request)
        request.responseWithDone({ _, json in
            self.FilteredList = json.arrayValue.map { data in
                STLecture(json: data)
            }
            self.searchState = .loaded(searchString, self.tagList)
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = 1
            self.reloadData()
        }, failure: { _ in
            self.searchState = .empty
            self.FilteredList = []
            self.reloadData()
        })
    }

    func getMoreLectureList(_ searchString: String) {
        let emptyTag = tagList.filter { tag -> Bool in
            tag.text == EtcTag.empty.rawValue
        }

        let mask = emptyTag.count != 0 ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: perPage * pageNum, limit: perPage))
        searchState = .loading(request)
        request.responseWithDone({ _, json in
            self.searchState = .loaded(searchString, self.tagList)
            self.FilteredList = self.FilteredList + json.arrayValue.map { data in
                STLecture(json: data)
            }
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = self.pageNum + 1
            self.reloadData()
        }, failure: { _ in
            self.searchState = .empty
            self.FilteredList = []
            self.reloadData()
        })
    }

    func setFocusToSearch() {
        searchBar.becomeFirstResponder()
    }

    let heightForFetch = CGFloat(50.0)

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch, !isLast {
            if case let SearchState.loaded(searchString, _) = searchState {
                getMoreLectureList(searchString)
            }
        }
    }

    @objc func timetableSwitched() {
        searchState = .empty
        searchBar.text = ""
        FilteredList = []
        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        tagTableView.filteredList = []
        tagCollectionView.tagList = []

        reloadTimetable()
        reloadData()
        tagTableView.hide()
        tagCollectionView.reloadData()
    }

    @objc func reloadTimetable() {
        timetableView.reloadTimetable()
        timetableView.reloadTempLecture()
    }

    @objc func reloadTempLecture() {
        timetableView.reloadTempLecture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in _: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch searchState {
        case .loaded:
            return 1
        case .loading, .empty, .editingQuery:
            return 0
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STLectureSearchTableViewCell", for: indexPath) as! STLectureSearchTableViewCell
        cell.lecture = FilteredList[indexPath.row]
        cell.tableView = tableView
        cell.quarter = STTimetableManager.sharedInstance.currentTimetable?.quarter

        cell.moveToReviewDetail = moveToReviewDetail

        return cell
    }

    func searchBarSearchButtonClicked(_ query: String) {
        switch searchState {
        case let .loading(request):
            request.cancel()
        default:
            break
        }
        getLectureList(query)
        reloadData()
    }

    func searchBarCancelButtonClicked() {
        switch searchState {
        case let .editingQuery(query, tagList, lectureList):
            searchState = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        case let .loading(request):
            request.cancel()
            searchState = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        default: break
        }
        reloadData()
        tagCollectionView.reloadData()
    }

    var willSelectRow: Bool = false
    var selectedRow: Int?

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == tableView.indexPathForSelectedRow {
            return 150
        } else {
            return 106
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        willSelectRow = false
        STTimetableManager.sharedInstance.setTemporaryLecture(FilteredList[indexPath.row], object: self)
        // TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        selectedRow = indexPath.row
        tableView.performBatchUpdates(nil, completion: nil)
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if STTimetableManager.sharedInstance.currentTimetable?.temporaryLecture == FilteredList[indexPath.row] && !willSelectRow {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        }
    }

    func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        willSelectRow = true
        return indexPath
    }

    func addTag(_ tag: STTag) {
        searchBar.disableEditingTag()
        tagCollectionView.tagList.append(tag)
        if tagCollectionView.tagList.count == 1 {
            let indexPath = IndexPath(row: 0, section: 0)
            tagCollectionView.reloadData()
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: false)
        } else {
            let indexPath = IndexPath(row: tagCollectionView.tagList.count - 1, section: 0)
            tagCollectionView.insertItems(at: [indexPath])
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
        }
        tagCollectionView.setHidden()
        tagTableView.hide()
        filterViewController?.currentDetailTagList = tagList
        filterViewController?.reloadSelectedTagList()
    }

    func removeTag(_ tag: STTag) {
        guard let index = tagCollectionView.tagList.index(of: tag) else { return }
        tagCollectionView.tagList.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tagCollectionView.deleteItems(at: [indexPath])

        filterViewController?.currentDetailTagList = tagList

        filterViewController?.reloadSelectedTagList()
    }

    func hideTagRecommendation() {
        tagTableView.hide()
    }

    // MARK: DNZEmptyDataSet

    var emptyInfoView: STSearchEmptyInfoView!
    var infoView: STTagSearchInfoView!
    var emptySearchView: UIView!
    var showInfo: Bool = false

    func initEmptyDataSet() {
        let emptyInfoViewNib = Bundle.main.loadNibNamed("STSearchEmptyInfoView", owner: nil, options: nil)
        emptyInfoView = emptyInfoViewNib![0] as! STSearchEmptyInfoView
        emptyInfoView.searchController = self

        let emptySearchViewNib = Bundle.main.loadNibNamed("STSearchEmptyView", owner: nil, options: nil)
        emptySearchView = emptySearchViewNib![0] as! UIView

        let infoViewNib = Bundle.main.loadNibNamed("STTagSearchInfoView", owner: nil, options: nil)
        if isLargerThanSE() {
            infoView = infoViewNib![0] as! STTagSearchInfoView
        } else {
            infoView = infoViewNib![1] as! STTagSearchInfoView
        }
        infoView.searchController = self
    }

    func customView(forEmptyDataSet _: UIScrollView!) -> UIView! {
        if case .loaded = searchState {
            return emptySearchView
        } else if case .empty = searchState {
            if showInfo {
                return infoView
            } else {
                return emptyInfoView
            }
        } else {
            return nil
        }
    }

    func emptyDataSetShouldDisplay(_: UIScrollView!) -> Bool {
        if searchBar.isFirstResponder {
            return false
        } else if case .loading = searchState {
            return false
        }
        return true
    }
}

// MARK: Filter view

extension STLectureSearchTableViewController: SearchFilterViewControllerDelegate {
    func search(_: SearchFilterViewController) {
        switch searchState {
        case let .loading(request):
            request.cancel()
        default:
            break
        }
        getLectureList(searchBar?.text ?? "")
        reloadData()
    }

    func addDetailTag(_: SearchFilterViewController, tag: STTag) {
        addTag(tag)
    }

    func removeDetailTag(_: SearchFilterViewController, tag: STTag) {
        removeTag(tag)
    }

    func hide(_: SearchFilterViewController) {
        toggleFilterView()
    }

    private func addShowFilterView() {
        filterViewController = SearchFilterViewController(nibName: "SearchFilterViewController", bundle: nil)
        filterViewController?.delegate = self

        tabBarController!.view.addSubview(filterViewController!.view)

        filterViewController!.view.frame.size.width = tabBarController!.view.frame.width
        filterViewController!.view.frame.origin.y = tabBarController!.view.frame.height
        filterViewController!.view.layer.masksToBounds = true
        filterViewController!.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        filterViewController!.view.layer.cornerRadius = 16
    }

    private func removeShowFilterView() {
        filterViewController?.view.removeFromSuperview()
        filterViewController = nil
    }

    private func addGestureRecognizers() {
        guard let panGR = filterViewPanGestureRecognizer, let tapGR = backgTapRecognizerWhenFilter else { return }
        filterViewController!.view.addGestureRecognizer(panGR)
        tableView.addGestureRecognizer(tapGR)
    }

    private func removeGestureRecognizersInFilter() {
        guard let panGR = filterViewPanGestureRecognizer, let tapGR = backgTapRecognizerWhenFilter else { return }
        filterViewController!.view.removeGestureRecognizer(panGR)
        tableView.removeGestureRecognizer(tapGR)
    }

    @objc private func didTapBackgView(_: UITapGestureRecognizer) {
        switch searchState {
        case .empty, .editingQuery:
            if tagList.count == 0 {
                searchBarCancelButtonClicked()
                searchBar.resignFirstResponder()
            }
        default:
            return
        }
    }

    @objc private func didTapBackgViewWhenFilter(_: UITapGestureRecognizer) {
        if filterViewState == .opened {
            toggleFilterView()
        } else if tagList.count == 0 {
            searchBarCancelButtonClicked()
            searchBar.resignFirstResponder()
        }
    }

    @objc private func didPanGestureActionInFilterView(_ sender: UIPanGestureRecognizer) {
        guard let filterView = filterViewController?.view else { return }
        let translation = sender.translation(in: filterView)
        sender.setTranslation(CGPoint.zero, in: filterView)

        if sender.state == .changed {
            guard translation.y >= 0 else { return }

            filterView.frame.origin.y += translation.y
        }

        let currentOrigin = filterView.frame.origin.y
        let halfOfHeight = filterView.frame.height / 2

        if sender.state == .ended {
            if sender.velocity(in: filterView).y > 400 {
                toggleFilterView()
            } else if currentOrigin <= tabBarController!.view.frame.height - halfOfHeight {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                    filterView.frame.origin.y = self.tabBarController!.view.frame.height - filterView.frame.height
                }
            } else {
                toggleFilterView()
            }
        }
    }

    func toggleFilterView() {
//        self.dismissKeyboard()
        searchBar.resignFirstResponder()

        switch filterViewState {
        case .closed:
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.filterViewController?.view.frame.origin.y = self.tabBarController!.view.frame.height - (self.filterViewController?.view.frame.height ?? 0)

            } completion: { _ in
                self.filterViewState = .opened
                self.addGestureRecognizers()
            }

        case .opened:
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                self.filterViewController?.view.frame.origin.y = self.tabBarController!.view.frame.height
            } completion: { _ in
                self.filterViewState = .closed
                self.removeGestureRecognizersInFilter()
            }
        }
    }
}

extension STLectureSearchTableViewController {
    private func moveToReviewDetail(withId id: String) {
        tabBarController?.selectedIndex = 2
        if let reviewNC = tabBarController?.viewControllers?[2] as? UINavigationController, let reviewVC = reviewNC.topViewController as? ReviewViewController {
            if reviewVC.isViewLoaded {
                reviewVC.loadDetailView(withId: id)
            } else {
                reviewVC.setIdForLoadDetailView(with: id)
            }
        }
    }
}
