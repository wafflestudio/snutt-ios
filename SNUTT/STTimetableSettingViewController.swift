//
//  STTimetableSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 7. 27..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import TTRangeSlider

class STTimetableSettingViewController: UITableViewController {

    @IBOutlet weak var trimmingSwitch: UISwitch!
    @IBOutlet weak var daySlider: TTRangeSlider!
    @IBOutlet weak var dayText: UILabel!
    @IBOutlet weak var timeSlider: TTRangeSlider!
    @IBOutlet weak var timeText: UILabel!
    
    func setInitialUI() {
        let dayRange = STDefaults[.dayRange]
        let timeRange = STDefaults[.timeRange]
        
        daySlider.selectedMinimum = Float(dayRange[0])
        daySlider.selectedMaximum = Float(dayRange[1])
        timeSlider.selectedMinimum = Float(timeRange[0])
        timeSlider.selectedMaximum = Float(timeRange[1])
        
        daySlider.step = 1.0
        timeSlider.step = 1.0
        
        daySlider.numberFormatterOverride = STDayFormatter()
        
        daySlider.minDistance = 2.0
        timeSlider.minDistance = 7.0
        
        setUI()
    }
    
    func setUI() {
        let sliders : [TTRangeSlider?] = [daySlider, timeSlider]
        var textColor : UIColor! = nil
        var tintColor : UIColor! = nil
        var handleColor : UIColor! = nil
        if STDefaults[.autoFit] {
            trimmingSwitch.isOn = true
            textColor = UIColor.gray
            tintColor = UIColor.lightGray
            handleColor = UIColor.lightGray
        } else {
            trimmingSwitch.isOn = false
            textColor = UIColor.black
            tintColor = UIColor.lightGray
            handleColor = UIColor.black
        }
        for slider in sliders {
            slider?.isEnabled = !STDefaults[.autoFit]
            slider?.tintColor = tintColor
            slider?.handleColor = handleColor
            slider?.minLabelColour = handleColor
            slider?.maxLabelColour = handleColor
            slider?.tintColorBetweenHandles = handleColor
        }
        dayText.textColor = textColor
        timeText.textColor = textColor
    }
    
    func saveSetting() {
        STDefaults[.autoFit] = trimmingSwitch.isOn
        STDefaults[.timeRange] = [Double(timeSlider.selectedMinimum),
                                  Double(timeSlider.selectedMaximum)]
        STDefaults[.dayRange] = [Int(daySlider.selectedMinimum),
                                 Int(daySlider.selectedMaximum)]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil { // check if it is popping from the navigation stack
            saveSetting()
            STEventCenter.sharedInstance.postNotification(event: .SettingChanged, object: self)
        }
    }
    
    @IBAction func autoFitValueChanged(_ sender: AnyObject) {
        saveSetting()
        setUI()
    }
}
