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
import SafariServices

class STLoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var loginCategoryButton: UIButton!
    @IBOutlet weak var registerCategoryButton: UIButton!
    
    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var registerAddOnLayoutConstraint:  NSLayoutConstraint!
    @IBOutlet weak var idTextField: STLoginTextField!
    @IBOutlet weak var passwordTextField: STLoginTextField!
    
    @IBOutlet weak var registerTabLayoutConstraint0: NSLayoutConstraint!
    @IBOutlet weak var registerTabLayoutConstraint1: NSLayoutConstraint!
    @IBOutlet weak var loginTabLayoutConstraint0: NSLayoutConstraint!
    @IBOutlet weak var loginTabLayoutConstraint1: NSLayoutConstraint!
    
    @IBOutlet weak var keyboardLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: STLoginTextField!
    @IBOutlet weak var passwordCheckTextField: STLoginTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fbButton: UIView!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var termsLabel: UILabel!
    
    @IBOutlet weak var bgRightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgLeftLayoutConstraint: NSLayoutConstraint!
    var isLoginTab : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        let lineColor : UIColor = HexColor("#FFFFFF", 0.6)
        
        submitButton.roundCorner(submitButton.frame.height / 2.0)
        submitButton.layer.borderColor = lineColor.CGColor
        submitButton.layer.borderWidth = 1.0
        
        fbButton.roundCorner(fbButton.frame.height / 2.0)
        fbButton.layer.borderColor = lineColor.CGColor
        fbButton.layer.borderWidth = 1.0
        
        //textField
        idTextField.delegate = self
        passwordTextField.delegate = self
        passwordCheckTextField.delegate = self
        emailTextField.delegate = self
        
        isLoginTab = true
        setViewsToLogin()
        self.loginContainerView.layoutIfNeeded()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animateBgScrollView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    func applicationDidEnterBackground() {
        self.bgImageView.superview?.layer.removeAllAnimations()
    }

    func applicationWillEnterForeground() {
        animateBgScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private let activeColor = UIColor.whiteColor()
    private let inactiveColor = UIColor(white: 1.0, alpha: 0.6)
    
    func setViewsToLogin() {
        registerCategoryButton.setTitleColor(inactiveColor, forState: .Normal)
        loginCategoryButton.setTitleColor(activeColor, forState: .Normal)
        submitButton.setTitle("로그인", forState: UIControlState.Normal)
        fbLabel.text = "페이스북으로 로그인"
        registerAddOnLayoutConstraint.priority = 900
        
        idTextField.returnKeyType = .Next
        passwordTextField.returnKeyType = .Go
        
        if passwordTextField.isFirstResponder() {
            passwordTextField.reloadInputViews()
        }
        
        registerTabLayoutConstraint0.active = false
        registerTabLayoutConstraint1.active = false
        loginTabLayoutConstraint0.active = true
        loginTabLayoutConstraint1.active = true
        
        passwordCheckTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func setViewsToRegister() {
        registerCategoryButton.setTitleColor(activeColor, forState: .Normal)
        loginCategoryButton.setTitleColor(inactiveColor, forState: .Normal)
        submitButton.setTitle("회원가입", forState: UIControlState.Normal)
        fbLabel.text = "페이스북으로 회원가입"
        registerAddOnLayoutConstraint.priority = 100
        
        
        loginTabLayoutConstraint0.active = false
        loginTabLayoutConstraint1.active = false
        registerTabLayoutConstraint0.active = true
        registerTabLayoutConstraint1.active = true
        
        idTextField.returnKeyType = .Next
        passwordTextField.returnKeyType = .Next
        passwordCheckTextField.returnKeyType = .Next
        emailTextField.returnKeyType = .Join
        
        if passwordTextField.isFirstResponder() {
            passwordTextField.reloadInputViews()
        }
    }
    
    
    @IBAction func loginCategoryButtonClicked() {
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.setViewsToLogin()
            self.loginContainerView.layoutIfNeeded()
            }, completion: nil)
        isLoginTab = true
    }
    
    @IBAction func registerCategoryButtonClicked() {
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.setViewsToRegister()
            self.loginContainerView.layoutIfNeeded()
            }, completion: nil)
        isLoginTab = false
    }
    
    @IBAction func fbButonClicked() {
        
        let done : (String) -> () = { token in
            STDefaults[.token] = token
            self.openMainController()
        }
        
        let registerFB : (String, String) -> () = { id, token in
            STNetworking.registerFB(id, token: token, done: done, failure: { _ in
                
            })
        }
        
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            let id = accessToken.userID
            let token = accessToken.tokenString
            registerFB(id, token)
        } else {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self, handler:{result, error in
                if error != nil {
                    STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                } else if result.isCancelled {
                    STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                } else {
                    let id = result.token.userID
                    let token = result.token.tokenString
                    registerFB(id, token)
                }
            })
        }
    }
    
    @IBAction func submitButtonClicked() {
        guard let id = idTextField.text, password = passwordTextField.text else {
            STAlertView.showAlert(title: "로그인/회원가입 실패", message: "아이디와 비밀번호를 입력해주세요.")
            return
        }
        
        if isLoginTab {
            STNetworking.loginLocal(id, password: password, done: { token in
                STDefaults[.token] = token
                self.openMainController()
                }, failure: { _ in
                //STAlertView.showAlert(title: "로그인 실패", message: "아이디나 비밀번호가 올바르지 않습니다.")
            })
        } else {
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
                self.openMainController()
            }, failure: { _ in
                //STAlertView.showAlert(title: "회원가입 실패", message: "회원가입에 실패하였습니다.")
            })
        }
    }
    
    @IBAction func termLabelClicked() {
        let url = STConfig.sharedInstance.baseURL + "/terms_of_service"
        let svc = SFSafariViewController(URL: NSURL(string: url)!)
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    
    func openMainController() {
        
        let openController : () -> () = { _ in
            if let deviceId = FIRInstanceID.instanceID().token() {
                STNetworking.addDevice(deviceId)
            }
            let appDelegate = UIApplication.sharedApplication().delegate!
            let window = appDelegate.window!!
            let mainController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
            window.rootViewController = mainController
        }
        
        STNetworking.getRecentTimetable({ timetable in
            STTimetableManager.sharedInstance.currentTimetable = timetable
            openController()
        }, failure: {
            openController()
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.beginAnimations(nil, context: nil)
        
        let userInfo = notification.userInfo
        let height = userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.height
        let duration = userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        keyboardLayoutConstraint.constant = height
        self.loginContainerView.superview!.layoutIfNeeded()
        
        UIView.commitAnimations()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.beginAnimations(nil, context: nil)
        
        let userInfo = notification.userInfo
        let duration = userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        keyboardLayoutConstraint.constant = 0
        self.loginContainerView.superview!.layoutIfNeeded()
        
        UIView.commitAnimations()
        
    }
    
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.view.endEditing(true)
        }
    }
    
    func animateBgScrollView() {
        //self.bgImageView.superview!.layoutIfNeeded()

        UIView.animateWithDuration(80.0, delay: 0.0, options: [.Autoreverse, .Repeat, .CurveLinear], animations: {
            let priority = self.bgLeftLayoutConstraint.priority
            self.bgLeftLayoutConstraint.priority = self.bgRightLayoutConstraint.priority
            self.bgRightLayoutConstraint.priority = priority
            self.bgImageView.superview!.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case idTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            if isLoginTab {
                submitButtonClicked()
                passwordTextField.resignFirstResponder()
            } else {
                passwordCheckTextField.becomeFirstResponder()
            }
        case passwordCheckTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            if isLoginTab {
                submitButtonClicked()
                passwordTextField.resignFirstResponder()
            }
        default:
            return true
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
