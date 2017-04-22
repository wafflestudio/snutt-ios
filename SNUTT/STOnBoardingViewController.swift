//
//  STOnBoardingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 22..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import Foundation

class STOnBoardingViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleImageView: UIImageView!

    @IBOutlet weak var pageControl: UIPageControl!

    var titleImages : [UIImage] = []
    var hadLoaded = false;
    var frameWidth : CGFloat = 0.0;

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleImages = [UIImage(named: "imgIntroTitle1")!,UIImage(named: "imgIntroTitle2")!,UIImage(named: "imgIntroTitle3")!]
        titleImageView.image = titleImages[0]
        titleImageView.contentMode = .scaleAspectFit

        scrollView.contentInset = UIEdgeInsets.zero

        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        let bgImage = UIImage(color: UIColor.black.withAlphaComponent(0.5));
        loginButton.setBackgroundImage(bgImage, for: .highlighted)
        registerButton.setBackgroundImage(bgImage, for: .highlighted)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if hadLoaded {
            return
        }
        hadLoaded = true

        let scrollViewFrame = scrollView.frame
        frameWidth = scrollViewFrame.size.width
        for i in 0 ..< 3 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "imgIntro" + String(i+1))
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            imageView.frame = CGRect(x: scrollViewFrame.size.width * CGFloat(i), y: 0, width: scrollViewFrame.size.width, height: scrollViewFrame.size.width / 1.25)
        }
        scrollView.contentSize = CGSize(width: scrollViewFrame.size.width * 3, height: scrollViewFrame.size.height)
    }

    //MARK: ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = pageControl.currentPage
        var nowPage = Int(floor((scrollView.contentOffset.x - pageWidth / 3.0) / pageWidth)) + 1
        nowPage = nowPage < 0 ? 0 : nowPage >= 3 ? 2 : nowPage
        pageControl.currentPage = nowPage
        if (currentPage != nowPage) {
            titleImageView.image = titleImages[nowPage]
        }

    }
    @IBAction func pageControlValueChanged(_ sender: Any) {
        let pControl = sender as! UIPageControl
        scrollView.setContentOffset(CGPoint(x: CGFloat(pControl.currentPage) * frameWidth, y: 0),animated: true)
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
