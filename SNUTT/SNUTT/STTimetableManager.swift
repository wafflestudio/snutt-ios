//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class STTimetableManager: NSObject {
    // MARK: Singleton

    fileprivate static var sharedManager: STTimetableManager?
    static var sharedInstance: STTimetableManager {
        if sharedManager == nil {
            sharedManager = STTimetableManager()
            let _ = STTagManager.sharedInstance
        }
        return sharedManager!
    }

    override fileprivate init() {
        super.init()
        loadData()
        if let timetableId = currentTimetable?.id {
            STNetworking.getTimetable(timetableId, done: { timetable in
                self.currentTimetable = timetable
            }, failure: { errorCode in
                if errorCode == STErrorCode.NO_NETWORK {
                    return
                } else {
                    self.currentTimetable = nil
                }
            })
        }
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableManager.saveData), event: STEvent.CurrentTimetableChanged, object: nil)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }

    var currentTimetable: STTimetable? {
        didSet {
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableSwitched, object: self)
            saveData()
        }
    }

    func loadData() {
        if let dict = STDefaults[.currentTimetable] {
            let timetable = STTimetable(json: JSON(dict))
            currentTimetable = timetable
        }
    }

    @objc func saveData() {
        let dict = currentTimetable?.toDictionary()
        STDefaults[.currentTimetable] = dict as? NSDictionary
        STDefaults.synchronize()
    }

    func addCustomLecture(_ lecture: STLecture, object: AnyObject?, done: (() -> Void)?, failure: (() -> Void)?) {
        if currentTimetable == nil {
            failure?()
            return
        }
        STNetworking.addCustomLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            done?()
        }, failure: {
            self.currentTimetable?.deleteLecture(lecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            failure?()
        }, confirmAction: {
            self.overwriteCustomLecture(lecture: lecture, object: object, done: done, failure: failure)
        })
    }

    func addLecture(_ lecture: STLecture, object: AnyObject?) {
        STNetworking.addLecture(currentTimetable!, lectureId: lecture.id!, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
        }, failure: {
            self.currentTimetable?.deleteLecture(lecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
        }, confirmAction: {
            self.overwriteLecture(lecture: lecture, object: object)
        })
    }

    func updateLecture(_ oldLecture: STLecture, newLecture: STLecture, done: @escaping () -> Void, failure: @escaping () -> Void) {
        if currentTimetable == nil {
            failure()
            return
        }
        guard let index = currentTimetable!.lectureList.index(where: { lec in
            lec.id == newLecture.id
        }) else {
            failure()
            return
        }

        currentTimetable!.updateLectureAtIndex(index, lecture: newLecture)
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)

        STNetworking.updateLecture(currentTimetable!, oldLecture: oldLecture, newLecture: newLecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            done()
        }, failure: {
            self.currentTimetable?.updateLectureAtIndex(index, lecture: oldLecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            failure()
        }, confirmAction: {
            self.updateToOverwriteCustomLecture(oldLecture, newLecture: newLecture, index: index, done: done, failure: failure)
        })
    }

    func overwriteLecture(lecture: STLecture, object: AnyObject?) {
        STNetworking.addLecture(currentTimetable!, lectureId: lecture.id!, isForced: true) { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
        } failure: {
            self.currentTimetable?.deleteLecture(lecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
        }
    }

    func overwriteCustomLecture(lecture: STLecture, object: AnyObject?, done: (() -> Void)?, failure: (() -> Void)?) {
        STNetworking.addCustomLecture(currentTimetable!, lecture: lecture, isForced: true) { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            done?()
        } failure: {
            self.currentTimetable?.deleteLecture(lecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            failure?()
        }
    }

    func updateToOverwriteCustomLecture(_ oldLecture: STLecture, newLecture: STLecture, index: Int, done: @escaping () -> Void, failure: @escaping () -> Void) {
        STNetworking.updateLecture(currentTimetable!, oldLecture: oldLecture, newLecture: newLecture, isForced: true, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            done()
        }, failure: {
            self.currentTimetable?.updateLectureAtIndex(index, lecture: oldLecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            failure()
        })
    }

    func deleteLectureAtIndex(_ index: Int, object: AnyObject?) {
        if currentTimetable == nil {
            return
        }
        let lecture = currentTimetable!.lectureList[index]
        currentTimetable?.deleteLectureAtIndex(index)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        STNetworking.deleteLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
        }, failure: {
            self.currentTimetable?.addLecture(lecture)
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
        })
    }

    // FIXME: Refactoring Needed
    func resetLecture(_ lecture: STLecture, done: @escaping () -> Void) {
        if currentTimetable == nil {
            return
        }
        guard let index = currentTimetable!.lectureList.index(where: { lec in
            lec.id == lecture.id
        }) else {
            done()
            return
        }

        STNetworking.resetLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            done()
        }, failure: nil)
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
    }

    func setTemporaryLecture(_ lecture: STLecture?, object: AnyObject?) {
        if currentTimetable?.temporaryLecture == lecture {
            return
        }
        currentTimetable?.temporaryLecture = lecture
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTemporaryLectureChanged, object: object)
    }
}
