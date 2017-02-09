//
//  STAddLocalIDViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField

class STAddLocalIDViewController: UIViewController {

    @IBOutlet weak var idTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordCheckTextField: B68UIFloatLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        let title = "아이디 추가 실패"
        var failure = false
        var message = ""
        
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let passwordCheck = passwordCheckTextField.text ?? ""
        
        if passwordCheck != password {
            failure = true
            message = "비밀번호 확인란과 비밀번호가 다릅니다."
        } else if !STUtil.validateId(id) {
            if (id.characters.count > 32 || id.characters.count < 4) {
                message = "아이디는 4자 이상, 32자 이하여야합니다."
            } else {
                message = "아이디는 영문자와 숫자로만 이루어져 있어야 합니다."
            }
            return
        } else if !STUtil.validatePassword(password) {
            var message : String = ""
            if (password.characters.count > 20  || password.characters.count < 6) {
                message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
            } else {
                message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
            }
            failure = true
        }
        if failure {
            STAlertView.showAlert(title: title, message: message)
        } else {
            STNetworking.addLocalID(id, password: password, done: {
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
