//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire

class STLectureSearchTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar : STSearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagCollectionView: STTagCollectionView!
    @IBOutlet weak var tagTableView: STTagListView!
    
    @IBOutlet weak var tagCollectionViewConstraint: NSLayoutConstraint!
    
    var timetableViewController : STTimetableCollectionViewController!
    
    var FilteredList : [STLecture] = []
    var pageNum : Int = 0
    
    enum SearchState {
        case Empty
        case Loading(Request)
        case Loaded(String)
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
        
        searchBar.searchController = self
        tagTableView.searchController = self
        tagCollectionView.searchController = self
        
        tableView.registerNib(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")
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
        let request = Alamofire.request(STSearchRouter.Search(query: searchString, tagList: tagCollectionView.tagList))
        state = .Loading(request)
        request.responseWithDone({ statusCode, json in
            self.state = .Loaded(searchString)
            self.FilteredList = json.arrayValue.map { data in
                return STLecture(json: data)
            }
            self.reloadData()
        }, failure: { _ in
            self.state = .Empty
            self.FilteredList = []
            self.reloadData()
        })
    }
    func getMoreLectureList() {
        /* //FIXME : DEBUG
        if isGettingLecture {
            return
        }
        isGettingLecture = true
        if pageNum == -1 {
            return
        }
        pageNum++
        let queryText = SearchingString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let currentCourseBook = STCourseBooksManager.sharedInstance.currentCourseBook!
        let url : String  = "http://snutt.kr/api/search_query?year=\(currentCourseBook.year)&semester=\(currentCourseBook.semester)&filter=&type=course_title&query_text=\(queryText)&page=\(pageNum)&per_page=30"
        let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: [])) as! NSDictionary
        let searchResult = jsonDictionary["lectures"] as! [NSDictionary]
        for it in searchResult {
            FilteredList.append(STLecture(json: it))
        }
        if searchResult.count != 30 {
            pageNum = -1
        }
        isGettingLecture = false
        */
    }
    
    func timetableSwitched() {
        state = .Empty
        searchBar.text = ""
        FilteredList = []
        self.timetableViewController.timetable = STTimetableManager.sharedInstance.currentTimetable
        tagTableView.filteredList = []
        tagCollectionView.tagList = []
        
        self.reloadTimetable()
        self.reloadData()
        tagTableView.hide()
        tagCollectionView.reloadData()
    }
    
    func reloadTimetable() {
        self.timetableViewController.reloadTimetable()
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
        case .Loading, .Empty:
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
        case .Loading(let request):
            request.cancel()
        default:
            break
        }
        state = .Empty
        FilteredList = []
        searchBar.text = ""
        tagCollectionView.tagList = []
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
    
    func showTagRecommendation(query: String) {
        tagTableView.showTagsFor(query)
    }
    
    func hideTagRecommendation() {
        tagTableView.hide()
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
