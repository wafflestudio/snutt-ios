//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class STTimetableManager : NSObject {
    
    // MARK: Singleton
    
    private static var sharedManager : STTimetableManager? = nil
    static var sharedInstance : STTimetableManager{
        get {
            if sharedManager == nil {
                sharedManager = STTimetableManager()
                let _ = STTagManager.sharedInstance
            }
            return sharedManager!
        }
    }
    private override init() {
        super.init()
        self.loadData()
        if let timetableId = currentTimetable?.id {
            STNetworking.getTimetable(timetableId, done: { timetable in
                //FIXME: current logic = if it is 404, just set it to nil
                self.currentTimetable = timetable
            }, failure: { _ in
            })
        }
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableManager.saveData), event: STEvent.CurrentTimetableChanged, object: nil)
    }
    
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    var currentTimetable : STTimetable? {
        didSet {
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableSwitched, object: self)
            saveData()
        }
    }
    
    func getDataPath() -> String {
        let directorys : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true)
        
        print("value of directorys is \(directorys)")
        
        let directories:[String] = directorys;
        let pathToFile = directories[0]; //documents directory
        
        let plistfile = "currentTimetable.plist"
        let plistpath = NSString(string: pathToFile).stringByAppendingPathComponent(plistfile)
        
        return plistpath
    }
    
    func loadData() {
        let fileManager = NSFileManager.defaultManager()
        let path = getDataPath()
        if fileManager.fileExistsAtPath(path) {
            let dict = NSDictionary(contentsOfFile: path)!
            let timetable = STTimetable(json: JSON(dict))
            currentTimetable = timetable
        }
    }
    
    func saveData() {
        if currentTimetable == nil {
            return
        }
        let path = getDataPath()
        let dict = currentTimetable!.toDictionary() as NSDictionary
        let tmp = dict.writeToFile(path, atomically: true)
        print("writing : \(tmp)")
    }
    
    func addLecture(var lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        if currentTimetable == nil {
            // FIXME:
            return STAddLectureState.Success
        }
        let ret = currentTimetable!.addLecture(lecture)
        if case STAddLectureState.Success = ret {
            STNetworking.addLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
                self.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                }, failure: {
                // TODO: show alertview for error
                self.currentTimetable?.deleteLecture(lecture)
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            })
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.ErrorTime = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.ErrorSameLecture = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
        
        return ret
    }
    
    func updateLecture(oldLecture : STLecture, newLecture : STLecture) {
        if currentTimetable == nil {
            return
        }
        let index = currentTimetable!.lectureList.indexOf({ lec in
            return lec.id == newLecture.id
        })!
        currentTimetable!.updateLectureAtIndex(index, lecture: newLecture)
        STNetworking.updateLecture(currentTimetable!, oldLecture: oldLecture, newLecture: newLecture, done: {
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            
            }, failure: {})
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
    }
    
    func deleteLectureAtIndex(index: Int, object : AnyObject? ) {
        if currentTimetable == nil {
            return
        }
        let lecture = currentTimetable!.lectureList[index]
        currentTimetable?.deleteLectureAtIndex(index)
        // TODO: case when it fails
        STNetworking.deleteLecture(currentTimetable!, lecture: lecture, done: {}, failure: {})
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
    func setTemporaryLecture(lecture :STLecture?, object : AnyObject? ) {
        //TODO: STEvent.tempLectureChanged for animation
        if currentTimetable?.temporaryLecture == lecture {
            return
        }
        currentTimetable?.temporaryLecture = lecture
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
}
