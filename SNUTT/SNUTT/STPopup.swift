//
//  STPopup.swift
//  SNUTT
//
//  Created by 최유림 on 2022/06/24.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STPopup {
    var key: String?
    var imageURL: String?
    var hiddenDays: Int?

    /// "n일 동안 보지 않기"를 누른 시점입니다.
    ///
    /// 현재 시점과 lastUpdate의 시점 간 차이가 hiddenDays보다 크면 팝업을 다시 띄웁니다.
    var lastUpdate: Date?

    init(json data: JSON) {
        key = data["key"].string
        imageURL = data["image_url"].string
        hiddenDays = data["hidden_days"].int ?? 0
    }
}

extension STPopup: Equatable {
    static func == (lhs: STPopup, rhs: STPopup) -> Bool {
        return lhs.key == rhs.key && lhs.imageURL == rhs.imageURL && lhs.hiddenDays == rhs.hiddenDays
    }
}

extension STPopup: DictionaryRepresentable {
    func dictionaryValue() -> NSDictionary {
        return [
            "key": key ?? "",
            "imageURL": imageURL ?? "",
            "hiddenDays": hiddenDays ?? 0,
            "lastUpdate": lastUpdate?.convertToString() ?? "",
        ]
    }

    init?(dictionary: NSDictionary?) {
        guard let dict = dictionary else { return }
        guard let key = dict["key"] as? String,
              let imageURL = dict["imageURL"] as? String,
              let hiddenDays = dict["hiddenDays"] as? Int,
              let lastUpdate = dict["lastUpdate"] as? String
        else {
            return nil
        }
        self.key = key
        self.imageURL = imageURL
        self.hiddenDays = hiddenDays
        self.lastUpdate = lastUpdate.convertToDate()
    }
}
