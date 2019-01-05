//
//  STCourseBookList.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

class STCourseBookListManager {
    let networkProvider: STNetworkProvider
    let errorHandler : STErrorHandler
    let disposeBag = DisposeBag()

    init(resolver r: Resolver) {
        networkProvider = r.resolve(STNetworkProvider.self)!
        errorHandler = r.resolve(STErrorHandler.self)!
        self.loadCourseBooks()
        self.getCourseBooks()
    }
    
    var courseBookList : [STCourseBook] = []
    
    func loadCourseBooks () {
        guard let courseBookList = NSKeyedUnarchiver.unarchiveObject(withFile: getDocumentsDirectory().appendingPathComponent("courseBookList.archive")) as? [NSDictionary] else {
            self.courseBookList = []
            return
        }
        self.courseBookList = courseBookList.map({ dict in
            return STCourseBook(dictionary: dict)!
        })
    }
    
    func saveCourseBooks () {
        NSKeyedArchiver.archiveRootObject(courseBookList.map({ book in
            return book.dictionaryValue()
        }), toFile: getDocumentsDirectory().appendingPathComponent("courseBookList.archive"))
    }
    
    func getCourseBooks () {
        networkProvider.rx.request(STTarget.GetCourseBookList())
            .subscribe(onSuccess: { [weak self] list in
                guard let self = self else { return }
                self.courseBookList = list
                STEventCenter.sharedInstance.postNotification(event: .CourseBookUpdated, object: nil)
                self.saveCourseBooks()
            }, onError: errorHandler.apiOnError)
    }
    
}
