//
//  STRegisterViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 27..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import AuthenticationServices
import ChameleonFramework
import Crashlytics
import SafariServices
import UIKit

class STRegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backBtnView: STViewButton!
    @IBOutlet weak var idTextField: STLoginTextField!
    @IBOutlet weak var passwordTextField: STLoginTextField!
    @IBOutlet weak var passwordCheckTextField: STLoginTextField!
    @IBOutlet weak var emailTextField: STLoginTextField!

    @IBOutlet weak var registerButton: STViewButton!
    @IBOutlet weak var facebookButton: STViewButton!
    @IBOutlet weak var appleButton: STViewButton!

    @IBOutlet weak var layoutConstraint1: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraint2: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraint3: NSLayoutConstraint!

    @IBOutlet weak var termView: UIView!

    var textFields: [STLoginTextField] {
        return [idTextField, passwordTextField, passwordCheckTextField, emailTextField]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let textFieldList = textFields
        for textField in textFieldList {
            textField.delegate = self
        }

        registerButton.buttonPressAction = {
            self.registerButtonClicked()
        }
        facebookButton.buttonPressAction = {
            self.fbButtonClicked()
        }
        appleButton.buttonPressAction = {
            self.appleButtonClicked()
        }
        backBtnView.buttonPressAction = {
            self.dismiss(animated: true, completion: nil)
        }

        let termTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(termLabelClicked))
        termView.addGestureRecognizer(termTapRecognizer)

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if UIScreen.main.bounds.height > 700 {
            layoutConstraint1.constant = 104
            layoutConstraint2.constant = 71
            layoutConstraint3.constant = 68
        }
        // Do any additional setup after loading the view.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func keyboardWillShow(noti _: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: {
            self.backBtnView.alpha = 0.0
        })
    }

    @objc func keyboardWillHide(noti _: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: {
            self.backBtnView.alpha = 1.0
        })
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? STLoginTextField else {
            return false
        }
        let textFieldList = textFields

        if let index = textFieldList.index(of: loginTextField) {
            if index == textFieldList.count - 1 {
                textField.resignFirstResponder()
                registerButtonClicked()
                return true
            }
            textFieldList[index + 1].becomeFirstResponder()
            return false
        }
        return false
    }

    func fbButtonClicked() {
        view.endEditing(true)
        STUser.tryFBLogin(controller: self)
    }

    func appleButtonClicked() {
        view.endEditing(true)
        appleLogin()
    }

    func registerButtonClicked() {
        view.endEditing(true)
        guard let id = idTextField.text, let password = passwordTextField.text else {
            STAlertView.showAlert(title: "로그인/회원가입 실패", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }

        if passwordCheckTextField.text != password {
            STAlertView.showAlert(title: "회원가입 실패", message: "비밀번호 확인란과 비밀번호가 다릅니다.")
            return
        } else if !STUtil.validateId(id) {
            var message = ""
            if id.characters.count > 32 || id.characters.count < 4 {
                message = "아이디는 4자 이상, 32자 이하여야합니다."
            } else {
                message = "아이디는 영문자와 숫자로만 이루어져 있어야 합니다."
            }
            STAlertView.showAlert(title: "회원가입 실패", message: message)
            return
        } else if !STUtil.validatePassword(password) {
            var message = ""
            if password.characters.count > 20 || password.characters.count < 6 {
                message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
            } else {
                message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
            }
            STAlertView.showAlert(title: "회원가입 실패", message: message)
            return
        }
        let emailText = emailTextField.text
        let email = emailText == "" ? nil : emailText
        STNetworking.registerLocal(id, password: password, email: email, done: { token, userId in
            STDefaults[.token] = token
            STDefaults[.userId] = userId
            #if DEBUG
            #else
                Crashlytics.sharedInstance().setUserIdentifier(userId)
            #endif
            STUser.loadMainPage()
        }, failure: {
            // STAlertView.showAlert(title: "회원가입 실패", message: "회원가입에 실패하였습니다.")
        })
    }

    @objc func termLabelClicked() {
        view.endEditing(true)
        let url = STConfig.sharedInstance.baseURL + "/terms_of_service"
        let svc = SFSafariViewController(url: URL(string: url)!)
        present(svc, animated: true, completion: nil)
    }

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
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

// MARK: - Apple Login

extension STRegisterViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    private func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let token = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
                STAlertView.showAlert(title: "로그인 실패", message: "애플 로그인에 실패했습니다.")
                return
            }

            STUser.tryAppleLogin(token: token)
        default:
            break
        }
    }

    // Handle error
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint(error)
    }
}
