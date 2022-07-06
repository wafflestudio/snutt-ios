//
//  STPopUp.swift
//  SNUTT
//
//  Created by 최유림 on 2022/06/24.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

/// 서버에서 받아오는 팝업 정보를 decode하여 저장할 때 사용합니다.
struct STPopUp {
    var key: String?
    var imageURL: String?
    var hiddenDays: Int?
    
    init(json data: JSON) {
        key = data["key"].string
        imageURL = data["image_url"].string
        hiddenDays = data["hidden_days"].int
    }
}

/// 서버에서 받아온 팝업들을 담아 앱 내부에서 사용합니다.
class STPopUpList {
    /// STPopUpList의 singleton 객체입니다.
    static var sharedInstance: STPopUpList?
    
    var popUpList: [STPopUp] = []
    
    /// 서버에서 최신 팝업 정보를 받아옵니다.
    static func getRecentPopUp() {
        STNetworking.getPopUps { popUps in
            #if DEBUG
            for pop in popUps {
                print(pop)
            }
            #endif
            STPopUpList.sharedInstance?.popUpList = popUps
        } failure: {}
    }
}

extension STPopUp: Equatable {
    static func ==(lhs: STPopUp, rhs: STPopUp) -> Bool {
        return lhs.key == rhs.key && lhs.imageURL == rhs.imageURL
    }
}
