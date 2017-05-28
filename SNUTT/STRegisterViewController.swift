//
//  STRegisterViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 27..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework
import SafariServices

class STRegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backBtnView: STViewButton!
    @IBOutlet weak var idTextField: STLoginTextField!
    @IBOutlet weak var passwordTextField: STLoginTextField!
    @IBOutlet weak var passwordCheckTextField: STLoginTextField!
    @IBOutlet weak var emailTextField: STLoginTextField!

    @IBOutlet weak var registerButton: STViewButton!
    @IBOutlet weak var facebookButton: STViewButton!

    @IBOutlet weak var policyLabel: UILabel!

    var textFields : [STLoginTextField] {
        get {
            return [idTextField, passwordTextField, passwordCheckTextField, emailTextField]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let textFieldList = self.textFields
        for textField in textFieldList {
            textField.delegate = self
        }

        registerButton.buttonPressAction = { _ in
            self.registerButtonClicked()
        }
        facebookButton.buttonPressAction = { _ in
            self.fbButtonClicked()
        }
        backBtnView.buttonPressAction = { _ in
            self.dismiss(animated: true, completion: nil)
        }

        let policyTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.termLabelClicked))
        policyLabel.addGestureRecognizer(policyTapRecognizer)

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func keyboardWillShow(noti : NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { _ in
            self.backBtnView.alpha = 0.0
        })
    }

    func keyboardWillHide(noti: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { _ in
            self.backBtnView.alpha = 1.0
        })
    }
    // MARK: TextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? STLoginTextField else {
            return false
        }
        let textFieldList = self.textFields

        if let index = textFieldList.index(of: loginTextField) {
            if index == textFieldList.count - 1 {
                textField.resignFirstResponder()
                return true
            }
            textFieldList[index + 1].becomeFirstResponder()
            return false
        }
        return false
    }

    func fbButtonClicked() {
        STUser.tryFBLogin(controller:self)
    }

    func registerButtonClicked() {
        guard let id = idTextField.text, let password = passwordTextField.text else {
            STAlertView.showAlert(title: "로그인/회원가입 실패", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }

        if passwordCheckTextField.text != password {
            STAlertView.showAlert(title: "회원가입 실패", message: "비밀번호 확인란과 비밀번호가 다릅니다.")
            return
        } else if !STUtil.validateId(id) {
            var message : String = ""
            if (id.characters.count > 32 || id.characters.count < 4) {
                message = "아이디는 4자 이상, 32자 이하여야합니다."
            } else {
                message = "아이디는 영문자와 숫자로만 이루어져 있어야 합니다."
            }
            STAlertView.showAlert(title: "회원가입 실패", message: message)
            return
        } else if !STUtil.validatePassword(password) {
            var message : String = ""
            if (password.characters.count > 20  || password.characters.count < 6) {
                message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
            } else {
                message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
            }
            STAlertView.showAlert(title: "회원가입 실패", message: message)
            return
        }
        let emailText = emailTextField.text
        let email = emailText == "" ? nil : emailText
        STNetworking.registerLocal(id, password: password, email: email, done: { token in
            STDefaults[.token] = token
            STUser.loadMainPage()
        }, failure: { _ in
            //STAlertView.showAlert(title: "회원가입 실패", message: "회원가입에 실패하였습니다.")
        })
    }

    func termLabelClicked() {
        let url = STConfig.sharedInstance.baseURL + "/terms_of_service"
        let svc = SFSafariViewController(url: URL(string: url)!)
        self.present(svc, animated: true, completion: nil)
    }

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
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
