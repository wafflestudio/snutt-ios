//
//  STSupportViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import B68UIFloatLabelTextField
import UIKit

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

    @IBAction func sendButtonClicked(_: AnyObject) {
        if !validateEmail() {
            showInvalidationAlert(withTitle: "이메일을 입력해 주세요")
            return
        }

        if !validateText() {
            showInvalidationAlert(withTitle: "내용을 입력해 주세요")
            return
        }

        let actions = [UIAlertAction(title: "취소", style: .cancel, handler: nil),
                       UIAlertAction(title: "전송", style: .default, handler: { _ in
                           let loadingView = STAlertView.showLoading(title: "전송 중")
                           STNetworking.sendFeedback(self.emailTextField.text, message: self.contentTextView.text, done: {
                               loadingView.dismiss(animated: true, completion: {
                                   self.navigationController?.popViewController(animated: true)
                                   STAlertView.showAlert(title: "전송되었습니다", message: "")
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

extension STSupportViewController {
    private func validateEmail() -> Bool {
        guard let email = emailTextField.text else {
            print("email text is nil")
            return false
        }
        return email.count > 0
    }

    private func validateText() -> Bool {
        return contentTextView.text.count > 0
    }

    private func showInvalidationAlert(withTitle: String) {
        STAlertView.showAlert(title: withTitle, message: "")
    }
}
