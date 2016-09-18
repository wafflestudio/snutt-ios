//
//  STAccountSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class STAccountSettingViewController: UITableViewController {
    
    var isNetworking = true;
    
    enum CellType {
        case RightDetail(title: String, detail: String)
        case Button(title: String)
        case RedButton(title: String)
    }
    
    enum Cell {
        case ShowId
        case ChangePassword
        case AttachLocalId
        case ShowFBId
        case DetachFB
        case AttachFB
        case ShowEmail
        case ChangeEmail
        case Unregister
        
        var cellType : CellType {
            switch (self) {
            case ShowId:
                return CellType.RightDetail(title: "아이디", detail: STUser.currentUser?.localId ?? "(없음)")
            case ChangePassword:
                return CellType.Button(title: "비밀번호 변경")
            case AttachLocalId:
                return .Button(title: "아이디 비번 추가")
            case ShowFBId:
                return .RightDetail(title: "페이스북 이름", detail: STUser.currentUser?.fbName ?? "(없음)")
            case DetachFB:
                return .Button(title: "페이스북 연동 취소")
            case AttachFB:
                return .Button(title: "페이스북 연동")
            case ShowEmail:
                return .RightDetail(title: "이메일", detail: STUser.currentUser?.email ?? "(없음)")
            case ChangeEmail:
                return .Button(title: "이메일 변경")
            case Unregister:
                return .RedButton(title: "회원탈퇴")
            }
        }
    }
    
    var cellList : [[Cell]] = []
    var fbSection : Int = 0
    var emailSection : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STAccountSettingViewController.userUpdated), event: STEvent.UserUpdated, object: nil)
        
        refreshCellList()
        getUser()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func userUpdated() {
        isNetworking = false
        refreshCellList()
        self.tableView.reloadData()
    }
    
    func getUser() {
        isNetworking = true;
        STUser.getUser()
    }
    
    func refreshCellList() {
        cellList = []
        
        if (STUser.currentUser?.localId == nil) {
            cellList.append([Cell.AttachLocalId])
        } else {
            cellList.append([Cell.ShowId, Cell.ChangePassword])
        }
        
        fbSection = cellList.count
        if (STUser.currentUser?.fbName == nil) {
            cellList.append([Cell.AttachFB])
        } else {
            cellList.append([Cell.ShowFBId, Cell.DetachFB])
        }
        
        emailSection = cellList.count
        cellList.append([Cell.ShowEmail, Cell.ChangeEmail])
        
        cellList.append([Cell.Unregister])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cellList.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = cellList[indexPath.section][indexPath.row].cellType
        switch cellType {
        case .RightDetail(let title, let detail):
            let cell = tableView.dequeueReusableCellWithIdentifier("RightDetailCell", forIndexPath: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = detail
            return cell
        case .Button(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell", forIndexPath: indexPath)
            cell.textLabel?.text = title
            cell.accessoryType = .DisclosureIndicator
            return cell
        case .RedButton(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier("RedButtonCell",forIndexPath: indexPath) as! STRedButtonTableViewCell
            cell.buttonLabel.text = title
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isNetworking {
            return
        }
        let cell = cellList[indexPath.section][indexPath.row]
        switch (cell) {
        case .AttachFB:
            let registerFB : (String, String) -> () = { id, token in
                STNetworking.attachFB(fb_id: id, fb_token: token, done: {
                    STUser.getUser()
                    self.refreshCellList()
                    self.tableView.reloadSections(NSIndexSet(index: self.fbSection), withRowAnimation: .Automatic)
                    }, failure: { _ in
                        return
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
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                    } else if result.isCancelled {
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                    } else {
                        let id = result.token.userID
                        let token = result.token.tokenString
                        registerFB(id, token)
                    }
                })
            }
            return
        case .AttachLocalId:
            //TODO: attach local ID
            return
        case .ChangeEmail:
            STAlertView.showAlert(title: "이메일 변경", message: "새로운 이메일 주소를 입력해주세요", configAlert: { alert in
                alert.addTextFieldWithConfigurationHandler({ textfield in
                    textfield.placeholder = "새로운 이메일 주소"
                    textfield.keyboardType = .EmailAddress
                })
                alert.addAction(UIAlertAction(title: "취소", style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "이메일 변경", style: .Default, handler: { _ in
                    if let email = alert.textFields?.first?.text {
                        if (STUtil.validateEmail(email)) {
                            STNetworking.editUser(email, done: {
                                STUser.currentUser?.email = email
                                self.tableView.reloadSections(NSIndexSet(index: self.emailSection), withRowAnimation: .Automatic)
                                }
                                , failure: {
                                    STAlertView.showAlert(title: "이메일 변경", message: "이메일 변경에 실패했습니다.")
                            })
                            return
                        }
                    }
                    STAlertView.showAlert(title: "이메일 변경", message: "올바른 이메일 주소를 입력해 주세요.")
                }))
            })
            return
        case .ChangePassword:
            STAlertView.showAlert(title: "비밀번호 변경", message: "새로운 비밀번호를 입력해주세요", configAlert: { alert in
                alert.addTextFieldWithConfigurationHandler({ textfield in
                    textfield.placeholder = "현재 비밀번호"
                    textfield.secureTextEntry = true
                })
                alert.addTextFieldWithConfigurationHandler({ textfield in
                    textfield.placeholder = "새로운 비밀번호"
                    textfield.secureTextEntry = true
                })
                alert.addTextFieldWithConfigurationHandler({ textfield in
                    textfield.placeholder = "새로운 비밀번호 확인"
                    textfield.secureTextEntry = true
                })
                alert.addAction(UIAlertAction(title: "취소", style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "비번 변경", style: .Default, handler: { _ in
                    let curPass = alert.textFields?[0].text ?? ""
                    let newPass = alert.textFields?[1].text ?? ""
                    let newPass2 = alert.textFields?[2].text ?? ""
                    if (newPass != newPass2) {
                        STAlertView.showAlert(title: "비밀번호 변경", message: "비밀번호와 비밀번호 확인란이 다릅니다.")
                        return
                    } else if (!STUtil.validatePassword(newPass)) {
                        var message : String = ""
                        if (newPass.characters.count > 20  || newPass.characters.count < 6) {
                            message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
                        } else {
                            message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
                        }
                        STAlertView.showAlert(title: "비밀번호 변경", message: message)
                        return
                    }
                    
                    STNetworking.changePassword(curPass, newPassword: newPass, done: { _ in
                        return
                        }, failure: { errMessage in
                            if let err = errMessage {
                                STAlertView.showAlert(title: "비밀번호 변경", message: err)
                            }
                    })
                }))
            })
            return
        case .DetachFB:
            if STUser.currentUser?.localId == nil {
                STAlertView.showAlert(title: "페이스북 연동 끊기", message: "현재 로그인 수단이 페이스북 밖에 없기 때문에, 페이스북 연동을 끊을 수 없습니다.")
                return
            }
            let detachAction = UIAlertAction(title: "페이스북 연동 끊기", style: .Destructive, handler: { _ in
                STNetworking.detachFB({ _ in
                    STUser.currentUser?.fbName = nil
                    self.refreshCellList()
                    self.tableView.reloadSections(NSIndexSet(index: self.fbSection), withRowAnimation: .Automatic)
                    }, failure: { _ in
                        return
                })
            })
            let cancelAction = UIAlertAction(title: "취소", style: .Cancel, handler: nil)
            STAlertView.showAlert(title: "페이스북 연동 끊기", message: "페이스북 연동을 끊겠습니까?", actions: [cancelAction, detachAction])
            return
        case .Unregister:
            let unregisterAction = UIAlertAction(title: "회원탈퇴", style: .Destructive, handler: { _ in
                STNetworking.unregister({ _ in
                    return
                })
            })
            let cancelAction = UIAlertAction(title: "취소", style: .Cancel, handler: nil)
            STAlertView.showAlert(title: "회원탈퇴", message: "SNUTT 회원 탈퇴를 하겠습니까?", actions: [cancelAction, unregisterAction])
            return
        default:
            return
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
