//
//  STAlertView.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STAlertView {
    
    // Possible TODO:
    // It does not do anything else other than show the alertview.
    // It would be good idea to make the alertview as stack internally and show them one by one,
    // or there can be other solutions.
    
    static fileprivate func createAlert(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    static fileprivate func showAlert(_ alert: UIAlertController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showAlert(title: String, message: String) {
        let alert = STAlertView.createAlert(title: title, message: message)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
        STAlertView.showAlert(alert)
    }
    
    static func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = STAlertView.createAlert(title: title, message: message)
        for it in actions {
            alert.addAction(it)
        }
        STAlertView.showAlert(alert)
    }
    static func showAlert(title: String, message: String, configAlert: (UIAlertController) -> ()) {
        let alert = STAlertView.createAlert(title: title, message: message)
        configAlert(alert)
        STAlertView.showAlert(alert)
    }
}
