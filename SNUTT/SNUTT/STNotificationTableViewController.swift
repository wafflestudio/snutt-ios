//
//  STNotificationTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Alamofire
import DZNEmptyDataSet
import UIKit

class STNotificationTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    let heightForFetch: CGFloat = .init(50.0)

    var notiList: [STNotification] = []
    var pageCnt: Int = 0
    var numPerPage: Int = 15

    var loading: Bool = false
    var isLast: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        STMainTabBarController.controller?.notificationController = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 27

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none

        let nib = UINib(nibName: "STNotificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "STNotificationTableViewCell")

        refreshList()

        refreshControl = UIRefreshControl()

        refreshControl?.addTarget(self, action: #selector(refreshList), for: UIControl.Event.valueChanged)

        STDefaults[.shouldShowBadge] = false
    }

    override func viewDidAppear(_: Bool) {
        if !loading, STDefaults[.shouldShowBadge] {
            refreshControl?.beginRefreshing()
            refreshList()
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notiList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STNotificationTableViewCell", for: indexPath) as! STNotificationTableViewCell
        let notification = notiList[indexPath.row]
        cell.notification = notification

        return cell
    }

    override func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let notification = notiList[indexPath.row]
        if case .Link = notification.type {
            return indexPath
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notiList[indexPath.row]
        if let linkNotification = notification as? STLinkNotification {
            guard let urlString = linkNotification.url,
                  let url = URL(string: urlString)
            else {
                return
            }
            UIApplication.shared.openURL(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: refresh

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch {
            if !loading, !isLast {
                getMoreList()
            }
        }
    }

    func getMoreList() {
        loading = true
        STNetworking.getNotificationList(numPerPage, offset: numPerPage * pageCnt, explicit: true, done: { list in
            self.loading = false
            self.notiList = self.notiList + list
            self.pageCnt += 1

            if list.count < self.numPerPage {
                self.isLast = true
            }
            self.tableView.reloadData()
        }, failure: {
            // There is no error other than networking error
            self.loading = false
        })
    }

    @objc func refreshList() {
        loading = true
        pageCnt = 0
        isLast = false
        STNetworking.getNotificationList(numPerPage, offset: numPerPage * pageCnt, explicit: true, done: { list in
            self.loading = false
            self.notiList = list
            if list.count < self.numPerPage {
                self.isLast = true
            }
            self.pageCnt += 1

            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            formatter.timeStyle = DateFormatter.Style.medium

            let title = "Last update: \(formatter.string(from: Date()))"
            self.refreshControl?.attributedTitle = NSAttributedString(string: title)

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, failure: {
            // There is no error other than networking error
            self.loading = false
        })
    }

    // MARK: DNZEmptyDataSet

    func image(forEmptyDataSet _: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "tabAlarmOn")
    }

    func imageTintColor(forEmptyDataSet _: UIScrollView!) -> UIColor! {
        return UIColor(white: 0.8, alpha: 1.0)
    }

    func title(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
        let text = "알림이 없습니다."
        let attributes: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.boldSystemFont(ofSize: 18.0),
        ]
        return NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }

    func description(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
        let text = "넣은 강좌의 수강편람이 바뀌거나, 새로운 수강편람이 뜨면 알림을 줍니다.".breakOnlyAtNewLineAndSpace
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 14.0),
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.lightGray,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraph,
        ]
        return NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}
