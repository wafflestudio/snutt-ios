//
//  STLoginViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework
import FBSDKLoginKit
import Firebase
import Crashlytics
import SafariServices
import AuthenticationServices

class STLoginViewController: UIViewController, UITextFieldDelegate, ASAuthorizationControllerDelegate {

    
    @IBOutlet weak var backBtnView: STViewButton!
    @IBOutlet weak var idTextField: STLoginTextField!
    @IBOutlet weak var passwordTextField: STLoginTextField!

    @IBOutlet weak var loginButton: STViewButton!
    @IBOutlet weak var facebookButton: STViewButton!
    @IBOutlet weak var appleButton: STViewButton!
    
    @IBOutlet weak var layoutConstraint1: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraint2: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraint3: NSLayoutConstraint!
    
    var textFields : [STLoginTextField] {
        get {
            return [idTextField, passwordTextField]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //textField
        let textFieldList = self.textFields
        for textField in textFieldList {
            textField.delegate = self
        }
        
        appleButton.buttonPressAction = {
            self.appleButonClicked()
        }

        loginButton.buttonPressAction = {
            self.loginButtonClicked()
        }
        
        facebookButton.buttonPressAction = {
            self.fbButonClicked()
        }
        
        backBtnView.buttonPressAction = {
            self.dismiss(animated: true, completion: nil)
        }

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if isLargerThanSE() {
            layoutConstraint1.constant = 118
            layoutConstraint2.constant = 96.5
            layoutConstraint3.constant = 98
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func keyboardWillShow(noti : NSNotification) {
        UIView.animate(withDuration: 1.0, animations: {
            self.backBtnView.alpha = 0.0
        })
    }

    @objc func keyboardWillHide(noti: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { 
            self.backBtnView.alpha = 1.0
        })
    }

    func fbButonClicked() {
        self.view.endEditing(true)
        STUser.tryFBLogin(controller: self)
    }
    
    func appleButonClicked() {
        self.view.endEditing(true)
        appleLogin()
    }
    
    func loginButtonClicked() {
        self.view.endEditing(true)
        guard let id = idTextField.text, let password = passwordTextField.text else {
            STAlertView.showAlert(title: "로그인/회원가입 실패", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }

        if id == "" || password == "" {
            STAlertView.showAlert(title: "로그인/회원가입 실패", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }

        STNetworking.loginLocal(id, password: password, done: { token, userId in
            STDefaults[.token] = token
            STDefaults[.userId] = userId
            #if DEBUG
            #else
                Crashlytics.sharedInstance().setUserIdentifier(userId)
            #endif
            STUser.loadMainPage()
        }, failure: { 
            //STAlertView.showAlert(title: "로그인 실패", message: "아이디나 비밀번호가 올바르지 않습니다.")
        })
    }

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
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
                loginButtonClicked()
                return true
            }
            textFieldList[index + 1].becomeFirstResponder()
            return false
        }
        return false
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

// MARK: - Apple Login
extension STLoginViewController: ASAuthorizationControllerPresentationContextProviding {
    private func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
                
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
            let userIdentifier = appleIDCredential.user
            
            guard let token = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
                STAlertView.showAlert(title: "로그인 실패", message: "애플 로그인에 실패했습니다.")
                return
            }
            
            STUser.tryAppleLogin(id: userIdentifier, token: token)
     
        default:
            break
        }
    }
        
    // Handle error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      debugPrint(error)
    }
}
