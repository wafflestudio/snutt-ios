//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet

class STLectureSearchTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var searchBar : STSearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagCollectionView: STTagCollectionView!
    @IBOutlet weak var tagTableView: STTagListView!
    
    @IBOutlet weak var tagCollectionViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var searchToolbarView: STLectureSearchToolbarView!
    
    @IBOutlet weak var timetableView: STTimetableCollectionView!
    var FilteredList : [STLecture] = []
    var pageNum : Int = 0
    var perPage : Int = 20
    var isLast : Bool = false
    
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
    
    var searchState : SearchState = SearchState.empty
    var filterViewState: FilterViewState = FilterViewState.closed
    
    var filterViewController: SearchFilterViewController?
    
    var tagList: [STTag] {
        return tagCollectionView.tagList
    }
    
    var backgroundTapGestureRecognizer: UITapGestureRecognizer?
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
        
        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        
        searchBar.searchController = self
        tagTableView.searchController = self
        tagCollectionView.searchController = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
        
        initEmptyDataSet()
        
        tableView.register(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")
        
        searchBar.showsBookmarkButton = true
        
        let filterImage = UIImage(image: UIImage(named: "filter"), scaledTo: CGSize(width: 24, height: 24))
        searchBar.setImage(filterImage, for: .bookmark, state: .normal)
        searchBar.placeholder = "ex) 대영 Paul"
        
        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.showTemporary = true
        settingChanged()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STLectureSearchTableViewController.settingChanged), event: STEvent.SettingChanged, object: nil)
        
        backgroundTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:)))

        filterViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureActionInFilterView(_:)))
        addShowFilterView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @objc func settingChanged() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
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
    
    func getLectureList(_ searchString : String) {
        // This is for saving the request
        isLast = false
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: 0, limit: perPage))
        searchState = .loading(request)
        request.responseWithDone({ statusCode, json in
            self.FilteredList = json.arrayValue.map { data in
                return STLecture(json: data)
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
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: perPage * pageNum, limit: perPage))
        searchState = .loading(request)
        request.responseWithDone({ statusCode, json in
            self.searchState = .loaded(searchString, self.tagList)
            self.FilteredList = self.FilteredList + json.arrayValue.map { data in
                return STLecture(json: data)
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
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch && !isLast{
            if case SearchState.loaded(let searchString, let _) = searchState {
                getMoreLectureList(searchString)
            }
        }
    }
    
    @objc func timetableSwitched() {
        searchState = .empty
        searchBar.text = ""
        FilteredList = []
        self.timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        tagTableView.filteredList = []
        tagCollectionView.tagList = []
        searchToolbarView.currentTagType = nil
        searchToolbarView.isEmptyTime = false
        
        self.reloadTimetable()
        self.reloadData()
        tagTableView.hide()
        tagCollectionView.reloadData()
    }
    
    @objc func reloadTimetable() {
        self.timetableView.reloadTimetable()
    }
    
    @objc func reloadTempLecture() {
        self.timetableView.reloadTempLecture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch searchState {
        case .loaded:
            return 1
        case .loading, .empty, .editingQuery:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STLectureSearchTableViewCell", for: indexPath) as! STLectureSearchTableViewCell
        cell.lecture = FilteredList[indexPath.row]
        cell.tableView = tableView
        return cell
    }
    
    func searchBarSearchButtonClicked(_ query : String) {
        switch searchState {
        case .loading(let request):
            request.cancel()
        default:
            break
        }
        getLectureList(query)
        reloadData()
    }
    func searchBarCancelButtonClicked() {
        switch searchState {
        case .editingQuery(let query, let tagList, let lectureList):
            searchState = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        case .loading(let request):
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        willSelectRow = false
        STTimetableManager.sharedInstance.setTemporaryLecture(FilteredList[indexPath.row], object: self)
        //TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if STTimetableManager.sharedInstance.currentTimetable?.temporaryLecture == FilteredList[indexPath.row] && !willSelectRow {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
    
    //MARK: DNZEmptyDataSet
    
    var emptyInfoView: STSearchEmptyInfoView!;
    var infoView: STTagSearchInfoView!;
    var emptySearchView: UIView!;
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
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
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
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if searchBar.isFirstResponder {
            return false
        } else if case .loading = searchState {
            return false
        }
        return true
    }
    
    
    @objc func dismissKeyboard() {
        if case let .editingQuery(query, tagList, lectureList) = searchState {
            searchBar.resignFirstResponder()
            searchBar.isEditingTag = false
            if query == nil {
                searchState = .empty
                FilteredList = []
                searchBar.text = ""
                tagCollectionView.tagList = []
            } else {
                searchState = .loaded(query!, tagList)
                FilteredList = lectureList
                searchBar.text = query!
                tagCollectionView.tagList = tagList
            }
            reloadData()
            tagCollectionView.reloadData()
            hideTagRecommendation()
        }
    }
}

// MARK: Filter view
extension STLectureSearchTableViewController: SearchFilterViewControllerDelegate {
    func search(_: SearchFilterViewController) {
        switch searchState {
        case .loading(let request):
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
        
        self.tabBarController!.view.addSubview(filterViewController!.view)
        
        filterViewController!.view.frame.size.width = self.tabBarController!.view.frame.width
        filterViewController!.view.frame.origin.y = self.tabBarController!.view.frame.height
        filterViewController!.view.layer.masksToBounds = true
        filterViewController!.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        filterViewController!.view.layer.cornerRadius = 16
    }
    
    private func addGestureRecognizers() {
        guard let panGR = filterViewPanGestureRecognizer, let tapGR = backgroundTapGestureRecognizer else { return }
        filterViewController!.view.addGestureRecognizer(panGR)
        tableView.addGestureRecognizer(tapGR)
    }
    
    private func removeGestureRecognizersInFilter() {
        guard let panGR = filterViewPanGestureRecognizer, let tapGR = backgroundTapGestureRecognizer else { return }
        filterViewController!.view.removeGestureRecognizer(panGR)
        tableView.removeGestureRecognizer(tapGR)
    }
    
    @objc private func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        if filterViewState == .opened {
            toggleFilterView()
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
            if (sender.velocity(in: filterView).y > 400) {
                toggleFilterView()
            } else if (currentOrigin <= self.tabBarController!.view.frame.height - halfOfHeight) {
                
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
                
            } completion: { finished in
                self.filterViewState = .opened
                self.addGestureRecognizers()
            }
            
        case .opened:
            UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseInOut) {
                self.filterViewController?.view.frame.origin.y = self.tabBarController!.view.frame.height
            } completion: { finished in
                self.filterViewState = .closed
                self.removeGestureRecognizersInFilter()
            }
        }
    }
}
