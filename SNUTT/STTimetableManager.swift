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
import RxCocoa

class STTimetableManager : ReactiveCompatible {

    // TODO: eager loading. (with alpha in actual timetable)

    let disposeBag = DisposeBag()
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let currentTimetableSubject = BehaviorRelay<STTimetable?>(value: nil)
    let currentTemporaryLectureSubject = BehaviorRelay<STLecture?>(value: nil)

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
    }
    
    private(set) var currentTimetable : STTimetable? {
        get {
            return currentTimetableSubject.value
        }
        set {
            let oldValue = currentTimetable
            currentTimetableSubject.accept(newValue)
            if oldValue?.id != newValue?.id {
                currentTemporaryLectureSubject.accept(nil)
            }
            saveData()
        }
    }

    private(set) var currentTemporaryLecture: STLecture? {
        get {
            return currentTemporaryLectureSubject.value
        }
        set {
            currentTemporaryLectureSubject.accept(newValue)
        }
    }

    func loadData() {
        if let dict = STDefaults[.currentTimetable] {
            let timetable = STTimetable(json: JSON(dict))
            currentTimetable = timetable
        }
    }
    
    func saveData() {
        // TODO: serialization by jsonDecoder
        let dict = currentTimetable?.toDictionary()
        STDefaults[.currentTimetable] = dict as? NSDictionary
        STDefaults.synchronize()
    }
    
    func addCustomLecture(_ lecture : STLecture) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current Timetable does not exist")
        }
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
        return networkProvider.rx.request(STTarget.AddCustomLecture(params: params, timetableId: currentTimetableId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
            }).asCompletable()
    }
    
    func addLecture(_ lectureId : String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist")
        }
        return networkProvider.rx.request(STTarget.AddLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
            }).asCompletable()
    }
    
    func updateLecture(_ oldLecture : STLecture, newLecture : STLecture, done: @escaping ()->(), failure: @escaping ()->()) {
        // TODO: return type as Completable
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

        STNetworking.updateLecture(currentTimetable!, oldLecture: oldLecture, newLecture: newLecture, done: { [weak self] newTimetable in
            self?.currentTimetable = newTimetable
            done()
            }, failure: {
                self.currentTimetable?.updateLectureAtIndex(index, lecture: oldLecture)
                failure()
        })
    }
    
    func deleteLectureAtIndex(_ index: Int) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist.")
        }
        guard let lectureId = currentTimetable?.lectureList[index].id else {
            return Completable.error("lecture does not have id")
        }
        return networkProvider.rx.request(STTarget.DeleteLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
                    })
            .asCompletable()
    }

    func updateTitle(title: String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist.")
        }
        return self.networkProvider.rx.request(STTarget.UpdateTimetable(params: .init(title: title), id: currentTimetableId))
            .do(onSuccess: { [weak self] _ in
                self?.currentTimetable?.title = title
                }, onError: self.errorHandler.apiOnError
            ).asCompletable()
    }

    func getTimetable(id: String) -> Completable {
        return networkProvider.rx.request(STTarget.GetTimetable(id: id))
            .do(onSuccess: { [weak self] timetable in
                self?.currentTimetable = timetable
                }, onError: errorHandler.apiOnError)
        .asCompletable()
    }

    func getRecentTimetable() -> Completable {
        return networkProvider.rx.request(STTarget.GetRecentTimetable())
            .do(onSuccess: { [weak self] timetable in
                self?.currentTimetable = timetable
                }, onError: { [weak self] error in
                    self?.errorHandler.apiOnError(error)
            }).asCompletable()
    }
    
    //FIXME: Refactoring Needed
    func resetLecture(_ lectureId: String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist")
        }
        return networkProvider.rx.request(STTarget.ResetLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: {[weak self] newTimetable in
                self?.currentTimetable?.lectureList = newTimetable.lectureList
                }, onError: errorHandler.apiOnError
            ).asCompletable()
    }
    
    func setTemporaryLecture(_ lecture :STLecture?) {
        // TODO: check timetable Id?
        currentTemporaryLecture = lecture
    }
}

extension Reactive where Base == STTimetableManager {
    var currentTimetable : Observable<STTimetable?> {
        return base.currentTimetableSubject.asObservable()
    }
    var currentTemporaryLecture: Observable<STLecture?> {
        return base.currentTemporaryLectureSubject.asObservable()
    }
}
