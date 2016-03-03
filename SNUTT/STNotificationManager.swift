//
//  STNotificationManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STNotificationManager {
    // MARK: Singleton
    
    private static var sharedManager : STNotificationManager? = nil
    static var sharedInstance : STNotificationManager{
        get {
            if sharedManager == nil {
                sharedManager = STNotificationManager()
            }
            return sharedManager!
        }
    }
    private init() {
        loadData()
    }
    
    let NumOfPage = 20
    
    var notificationList : [STNotification] = []
    
    
    //TODO : Networking + local save
    func loadData() {
        notificationList = [STNotification(category: 0, body: "2016년도 1학기 수강편람이 나왔습니다."), STNotification(category: 1, body: "2016년도 1학기 \"테스트1\"시간표의 컴퓨터 구조 수업의 시간이 바뀌었습니다.")]
    }
    
    func saveData() {
        
    }
    
    func getData() {
        
    }
    
    func getNextPage() {
        
    }
}