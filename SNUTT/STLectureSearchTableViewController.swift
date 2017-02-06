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
    var timetableViewController : STTimetableCollectionViewController!
    
    var FilteredList : [STLecture] = []
    var pageNum : Int = 0
    var perPage : Int = 20
    var isLast : Bool = false
    
    enum SearchState {
        case Empty
        case EditingQuery(String?, [STTag], [STLecture])
        case Loading(Request)
        case Loaded(String, [STTag])
    }
    var state : SearchState = SearchState.Empty
    
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
        
        tableView.registerNib(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")
        
        //Tag Button to KeyboardToolbar
        
        searchBar.inputAccessoryView = searchToolbarView
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func getLectureList(searchString : String) {
        // This is for saving the request
        isLast = false
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.Search(query: searchString, tagList: tagList, mask: mask, offset: 0, limit: perPage))
        state = .Loading(request)
        request.responseWithDone({ statusCode, json in
            self.FilteredList = json.arrayValue.map { data in
                return STLecture(json: data)
            }
            self.state = .Loaded(searchString, tagList)
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = 1
            self.reloadData()
        }, failure: { _ in
            self.state = .Empty
            self.FilteredList = []
            self.reloadData()
        })
    }
    
    func getMoreLectureList(searchString: String) {
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? STTimetableManager.sharedInstance.currentTimetable?.timetableReverseTimeMask() : nil
        let request = Alamofire.request(STSearchRouter.Search(query: searchString, tagList: tagList, mask: mask, offset: perPage * pageNum, limit: perPage))
        state = .Loading(request)
        request.responseWithDone({ statusCode, json in
            self.state = .Loaded(searchString, tagList)
            self.FilteredList = self.FilteredList + json.arrayValue.map { data in
                return STLecture(json: data)
            }
            if json.arrayValue.count < self.perPage {
                self.isLast = true
            }
            self.pageNum = self.pageNum + 1
            self.reloadData()
            }, failure: { _ in
                self.state = .Empty
                self.FilteredList = []
                self.reloadData()
        })

    }
    
    let heightForFetch = CGFloat(50.0)
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch && !isLast{
            if case SearchState.Loaded(let searchString, let _) = state {
                getMoreLectureList(searchString)
            }
        }
    }
    
    func timetableSwitched() {
        state = .Empty
        searchBar.text = ""
        FilteredList = []
        self.timetableViewController.timetable = STTimetableManager.sharedInstance.currentTimetable
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
        self.timetableViewController.reloadTimetable()
    }
    
    func reloadTempLecture() {
        self.timetableViewController.reloadTempLecture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch state {
        case .Loaded:
            return 1
        case .Loading, .Empty, .EditingQuery:
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STLectureSearchTableViewCell", forIndexPath: indexPath) as! STLectureSearchTableViewCell
        cell.addSubview(cell.addButton)
        cell.lecture = FilteredList[indexPath.row]
        cell.tableView = tableView
        cell.titleLabel.sizeToFit()
        //cell.button.hidden = true
        return cell
    }
    
    func searchBarSearchButtonClicked(query : String) {
        switch state {
        case .Loading(let request):
            request.cancel()
        default:
            break
        }
        getLectureList(query)
        reloadData()
    }
    func searchBarCancelButtonClicked() {
        switch state {
        case .EditingQuery(let query, let tagList, let lectureList):
            if query == nil {
                state = .Empty
                FilteredList = []
                searchBar.text = ""
                tagCollectionView.tagList = []
            } else {
                state = .Loaded(query!, tagList)
                FilteredList = lectureList
                searchBar.text = query!
                tagCollectionView.tagList = tagList
            }
        case .Loading(let request):
            request.cancel()
            state = .Empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        default: break
        }
        reloadData()
        tagCollectionView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        STTimetableManager.sharedInstance.setTemporaryLecture(FilteredList[indexPath.row], object: self)
        //TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if STTimetableManager.sharedInstance.currentTimetable?.temporaryLecture == FilteredList[indexPath.row] {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        }
    }
    
    func addTag(tag: STTag) {
        searchBar.disableEditingTag()
        tagCollectionView.tagList.append(tag)
        if tagCollectionView.tagList.count == 1 {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tagCollectionView.reloadData()
            tagCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
        } else {
            let indexPath = NSIndexPath(forRow: tagCollectionView.tagList.count - 1, inSection: 0)
            tagCollectionView.insertItemsAtIndexPaths([indexPath])
            tagCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
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
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        // TODO: change the images
        switch(state) {
        case .Empty:
            return UIImage(named: "tag_white")
        case .Loaded:
            return UIImage(named: "tabbaritem_timetable")
        default:
            return nil
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .Empty:
            text = "강좌명 외의 내용으로 검색하려면 태그 검색을 이용하세요."
        case .Loaded:
            text = "검색 내용에 해당되는 강좌가 없습니다."
        default:
            text = ""
        }
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.65)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .Empty:
            text = "같은 분야의 태그를 넣으면 그 중 하나가 있으면, 다른 분야의 태그끼리는 모두 있는 강좌를 검색합니다.\n예) #3학점, #4학점 : 3 또는 4학점\n#컴퓨터공학부, #전필 : 컴퓨터공학부 과목들 중 전필 강좌".breakOnlyAtNewLineAndSpace
        case .Loaded:
            text = ""
        default:
            text = ""
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.5),
            NSParagraphStyleAttributeName : paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState _: UIControlState) -> NSAttributedString! {
        var text : String = ""
        switch(state) {
        case .Empty:
            text = "태그 추가하기"
        case .Loaded:
            text = ""
        default:
            text = ""
        }
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.searchBar.enableEditingTag()
        self.searchBar.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        if case .EditingQuery = state {
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STSearchTimetableView") {
            timetableViewController = (segue.destinationViewController as! STTimetableCollectionViewController)
            timetableViewController.timetable = STTimetableManager.sharedInstance.currentTimetable
            timetableViewController.showTemporary = true
        }
    }
    

}
