//
//  STPrivacyPolicyViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 13..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STPrivacyPolicyViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string: STConfig.sharedInstance.baseURL + "/privacy_policy")!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
