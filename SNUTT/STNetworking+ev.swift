//
//  STNetworking+ev.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/02/06.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

// for SNUTT-ev api
extension STNetworking {
    static func getReviewIdFromLecture(_ courseNumber: String, _ instructor: String, _ done: @escaping (String) -> Void, failure: @escaping () -> Void) {
        Alamofire.request(STEVRouter.getReviewId(courseNumber: courseNumber, instructor: instructor)).responseWithDone({ _, json in

            if let id = json.dictionaryValue["id"]?.number {
                done(id.stringValue)
            } else {
                STAlertView.showAlert(title: "", message: "강의평을 찾을 수 없습니다")
                return
            }
        }, failure: { _ in
            failure()
        })
    }
}
