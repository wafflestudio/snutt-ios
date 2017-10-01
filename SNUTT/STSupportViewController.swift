//
//  STSupportViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STSupportViewController: UIViewController {

    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var contentTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        let actions = [UIAlertAction(title: "취소", style: .cancel, handler: nil),
                       UIAlertAction(title: "전송", style: .default, handler: { action in
            let loadingView = STAlertView.showLoading(title: "전송 중")
            STNetworking.sendFeedback(self.emailTextField.text, message: self.contentTextView.text, done: {
                loadingView.dismiss(animated: true, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }, failure: {
                loadingView.dismiss(animated: true)
            })
        })]

        STAlertView.showAlert(title: "전송 확인", message: "개발자에게 메세지를 전송하시겠습니까?", actions: actions)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
