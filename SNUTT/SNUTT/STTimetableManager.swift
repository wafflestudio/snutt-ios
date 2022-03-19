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
        var lecture = lecture
        if currentTimetable == nil {
            failure?()
            return
        }
        let ret = currentTimetable!.addLecture(lecture)
        if case STAddLectureState.success = ret {
            STNetworking.addCustomLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
                self.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                done?()
            }, failure: {
                self.currentTimetable?.deleteLecture(lecture)
                failure?()
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            })
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.errorTime = ret {
            failure?()
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.errorSameLecture = ret {
            failure?()
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
    }

    func addLecture(_ lecture: STLecture, object: AnyObject?) -> STAddLectureState {
        var lecture = lecture
        if currentTimetable == nil {
            return STAddLectureState.success
        }
        let ret = currentTimetable!.addLecture(lecture)
        if case STAddLectureState.success = ret {
            STNetworking.addLecture(currentTimetable!, lectureId: lecture.id!, done: { newTimetable in
                self.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            }, failure: {
                self.currentTimetable?.deleteLecture(lecture)
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            })
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.errorTime = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.errorSameLecture = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }

        return ret
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
