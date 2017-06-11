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
    var state : SearchState = SearchState.empty
    
    func reloadData() {
        tableView.reloadData()
        STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        STEventCenter.sharedInstance.addObserver(self, selector: "timetableSwitched", event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadTimetable", event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadTempLecture", event: STEvent.CurrentTemporaryLectureChanged, object: nil)
        
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
        
        //Tag Button to KeyboardToolbar
        
        searchBar.inputAccessoryView = searchToolbarView

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.showTemporary = true
        settingChanged()
        STEventCenter.sharedInstance.addObserver(self, selector: "settingChanged", event: STEvent.SettingChanged, object: nil)
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

    func settingChanged() {
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
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: 0, limit: perPage))
        state = .loading(request)
        request.responseWithDone({ statusCode, json in
            self.FilteredList = json.arrayValue.map { data in
                return STLecture(json: data)
            }
            self.state = .loaded(searchString, tagList)
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = 1
            self.reloadData()
        }, failure: { _ in
            self.state = .empty
            self.FilteredList = []
            self.reloadData()
        })
    }
    
    func getMoreLectureList(_ searchString: String) {
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.search(query: searchString, tagList: tagList, mask: mask, offset: perPage * pageNum, limit: perPage))
        state = .loading(request)
        request.responseWithDone({ statusCode, json in
            self.state = .loaded(searchString, tagList)
            self.FilteredList = self.FilteredList + json.arrayValue.map { data in
                return STLecture(json: data)
            }
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = self.pageNum + 1
            self.reloadData()
            }, failure: { _ in
                self.state = .empty
                self.FilteredList = []
                self.reloadData()
        })

    }
    
    let heightForFetch = CGFloat(50.0)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch && !isLast{
            if case SearchState.loaded(let searchString, let _) = state {
                getMoreLectureList(searchString)
            }
        }
    }
    
    func timetableSwitched() {
        state = .empty
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
    
    func reloadTimetable() {
        self.timetableView.reloadTimetable()
    }
    
    func reloadTempLecture() {
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
        switch state {
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
        cell.addSubview(cell.addButton)
        cell.lecture = FilteredList[indexPath.row]
        cell.tableView = tableView
        cell.titleLabel.sizeToFit()
        //cell.button.hidden = true
        return cell
    }
    
    func searchBarSearchButtonClicked(_ query : String) {
        switch state {
        case .loading(let request):
            request.cancel()
        default:
            break
        }
        getLectureList(query)
        reloadData()
    }
    func searchBarCancelButtonClicked() {
        switch state {
        case .editingQuery(let query, let tagList, let lectureList):
            state = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        case .loading(let request):
            request.cancel()
            state = .empty
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
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: false)
        } else {
            let indexPath = IndexPath(row: tagCollectionView.tagList.count - 1, section: 0)
            tagCollectionView.insertItems(at: [indexPath])
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
        }
        tagCollectionView.setHidden()
        tagTableView.hide()
    }
    
    func showTagRecommendation() {
        tagTableView.showTagsFor(searchBar.text!, type: searchToolbarView.currentTagType)
        tagTableView.setContentOffset(CGPoint(x: 0, y: -tagTableView.contentInset.top), animated: true)
    }
    
    func hideTagRecommendation() {
        tagTableView.hide()
    }
    
    //MARK: DNZEmptyDataSet

    var emptyView: STSearchEmptyView!;
    var infoView: STTagSearchInfoView!;
    var showInfo: Bool = false

    func initEmptyDataSet() {
        let emptyViewNib = Bundle.main.loadNibNamed("STSearchEmptyView", owner: nil, options: nil)
        emptyView = emptyViewNib![0] as! STSearchEmptyView
        emptyView.searchController = self

        let infoViewNib = Bundle.main.loadNibNamed("STTagSearchInfoView", owner: nil, options: nil)
        infoView = infoViewNib![0] as! STTagSearchInfoView
        infoView.searchController = self
    }

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        if showInfo {
            return infoView
        } else {
            return emptyView
        }
    }
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if searchBar.isFirstResponder {
            return false
        } else if case .loading = state {
            return false
        }
        return true
    }


    func dismissKeyboard() {
        if case let .editingQuery(query, tagList, lectureList) = state {
            searchBar.resignFirstResponder()
            searchBar.isEditingTag = false
            state = .loaded(query!, tagList)
            FilteredList = lectureList
            searchBar.text = query!
            tagCollectionView.tagList = tagList
            reloadData()
            tagCollectionView.reloadData()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    

}
