//
//  STNetworking.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

class STNetworking {
    //MARK: Others

    static func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "네트워크 환경이 원활하지 않습니다.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.shared.keyWindow!.rootViewController!.present(alert, animated: true, completion: nil)
    }

}
