//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

class STTimetableManager {

    let disposeBag = DisposeBag()
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!

    init() {
        self.loadData()
        if let timetableId = currentTimetable?.id {
            networkProvider.rx.request(STTarget.GetTimetable(id: timetableId))
                .subscribe(onSuccess: { [weak self] timetable in
                    self?.currentTimetable = timetable
                    }, onError: { [weak self] e in
                        self?.errorHandler.apiOnError(e)
                        self?.currentTimetable = nil
                })
                .disposed(by: disposeBag)
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
    
    func addCustomLecture(_ lecture : STLecture, object : AnyObject?, done: (()->())?, failure: (()->())?) {
        var lecture = lecture
        guard let currentTimetable = currentTimetable else {
            failure?()
            return
        }
        let ret = currentTimetable.addLecture(lecture)
        if case STAddLectureState.success = ret {

            let params = STTarget.AddCustomLecture.Params(
                classification: lecture.classification,
                department: lecture.department,
                academic_year: lecture.academicYear,
                course_number: lecture.courseNumber,
                lecture_number: lecture.lectureNumber,
                course_title: lecture.title,
                credit: lecture.credit,
                instructor: lecture.instructor,
                quota: lecture.quota,
                remark: lecture.remark,
                category: lecture.category,
                class_time_json: lecture.classList,
                color: lecture.color,
                colorIndex: lecture.colorIndex
            )
            networkProvider.rx.request(STTarget.AddCustomLecture(params: params, timetableId: currentTimetable.id!))
                .subscribe(onSuccess: { [weak self] newTimetable in
                    self?.currentTimetable?.lectureList = newTimetable.lectureList
                    STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                    done?()
                    }, onError: { [weak self] err in
                        self?.errorHandler.apiOnError(err)
                        self?.currentTimetable?.deleteLecture(lecture)
                        failure?()
                        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)

                })
                .disposed(by: disposeBag)
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.errorTime = ret {
            failure?()
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.errorSameLecture = ret {
            failure?()
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
    }
    
    func addLecture(_ lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        guard let currentTimetable = currentTimetable else {
            return STAddLectureState.success
        }
        let ret = currentTimetable.addLecture(lecture)
        if case STAddLectureState.success = ret {
            networkProvider.rx.request(STTarget.AddLecture(timetableId: currentTimetable.id!, lectureId: lecture.id!))
                .subscribe(onSuccess: { [weak self] newTimetable in
                    self?.currentTimetable?.lectureList = newTimetable.lectureList
                    STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                }, onError: { [weak self] err in
                    self?.currentTimetable?.deleteLecture(lecture)
                    STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                })
                .disposed(by: disposeBag)
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.errorTime = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.errorSameLecture = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
        
        return ret
    }
    
    func updateLecture(_ oldLecture : STLecture, newLecture : STLecture, done: @escaping ()->(), failure: @escaping ()->()) {
        if currentTimetable == nil {
            failure()
            return
        }
        guard let index = currentTimetable!.lectureList.index(where: { lec in
            return lec.id == newLecture.id
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
    
    func deleteLectureAtIndex(_ index: Int, object : AnyObject? ) {
        guard let currentTimetable = currentTimetable else {
            return
        }
        let lecture = currentTimetable.lectureList[index]
        currentTimetable.deleteLectureAtIndex(index)
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        networkProvider.rx.request(STTarget.DeleteLecture(timetableId: currentTimetable.id!, lectureId: lecture.id!))
            .subscribe(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
                    self?.currentTimetable?.addLecture(lecture)
                    STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            })
            .disposed(by: disposeBag)
    }
    
    
    //FIXME: Refactoring Needed
    func resetLecture(_ lecture: STLecture, done: @escaping ()->()) {
        guard let currentTimetable = currentTimetable else {
            return
        }
        guard let index = currentTimetable.lectureList.index(where: { lec in
            return lec.id == lecture.id
        }) else {
            done()
            return
        }
        networkProvider.rx.request(STTarget.ResetLecture(timetableId: currentTimetable.id!, lectureId: lecture.id!))
            .subscribe(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            }, onError: errorHandler.apiOnError)
            .disposed(by: disposeBag)
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
    }
    
    func setTemporaryLecture(_ lecture :STLecture?, object : AnyObject? ) {
        if currentTimetable?.temporaryLecture == lecture {
            return
        }
        currentTimetable?.temporaryLecture = lecture
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTemporaryLectureChanged, object: object)
    }
}
