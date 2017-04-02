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
        
        tableView.register(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")
        
        //Tag Button to KeyboardToolbar
        
        searchBar.inputAccessoryView = searchToolbarView

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.showTemporary = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
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
            if query == nil {
                state = .empty
                FilteredList = []
                searchBar.text = ""
                tagCollectionView.tagList = []
            } else {
                state = .loaded(query!, tagList)
                FilteredList = lectureList
                searchBar.text = query!
                tagCollectionView.tagList = tagList
            }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        STTimetableManager.sharedInstance.setTemporaryLecture(FilteredList[indexPath.row], object: self)
        //TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if STTimetableManager.sharedInstance.currentTimetable?.temporaryLecture == FilteredList[indexPath.row] {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        }
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
    }
    
    func hideTagRecommendation() {
        tagTableView.hide()
    }
    
    //MARK: DNZEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        switch(state) {
        case .empty:
            return UIImage(named: "tag_gray")
        case .loaded:
            return UIImage(named: "tabbaritem_search")
        default:
            return nil
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .empty:
            text = "강좌명 외의 내용으로 검색하려면 태그 검색을 이용하세요."
        case .loaded:
            text = "검색 내용에 해당되는 강좌가 없습니다."
        default:
            text = ""
        }
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.65)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .empty:
            text = "같은 분야의 태그를 넣으면 그 중 하나가 있으면, 다른 분야의 태그끼리는 모두 있는 강좌를 검색합니다.\n예) #3학점, #4학점 : 3 또는 4학점\n#컴퓨터공학부, #전필 : 컴퓨터공학부 과목들 중 전필 강좌".breakOnlyAtNewLineAndSpace
        case .loaded:
            text = ""
        default:
            text = ""
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 14.0),
            NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.5),
            NSParagraphStyleAttributeName : paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for _: UIControlState) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .empty:
            text = "태그 추가하기"
        case .loaded:
            text = ""
        default:
            text = ""
        }
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17.0),
            NSForegroundColorAttributeName : UIColor.white
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.searchBar.enableEditingTag()
        self.searchBar.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        if case .editingQuery = state {
            self.searchBar.searchBarCancelButtonClicked(self.searchBar)
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
