//
//  STCourseCellCollectionViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STCourseCellCollectionViewCell: UICollectionViewCell, UIAlertViewDelegate {
    @IBOutlet var courseText: UILabel!
    public private(set) var singleClass: STSingleClass!
    public private(set) var lecture: STLecture!
    private var oldLecture: STLecture?
    private var oldSingleClass: STSingleClass?
    var theme: STTheme?

    var longClicked: ((STCourseCellCollectionViewCell) -> Void)?
    var tapped: ((STCourseCellCollectionViewCell) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        var margin: CGFloat = 4.0
        if isLargerThanSE() {
            margin = 5.0
        }
        layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longClick))
        addGestureRecognizer(longPress)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        addGestureRecognizer(tap)

        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05).cgColor
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }

    func setData(lecture: STLecture, singleClass: STSingleClass) {
        // TODO: oldLecture 둔 이유가 뭔가요?
//        if (oldLecture == lecture && oldSingleClass == singleClass) {
//            return
//        }
        self.lecture = lecture
        self.singleClass = singleClass
        setText()
        setColor()
//        oldLecture = lecture
//        oldSingleClass = singleClass
    }

    func setColorByLecture(lecture: STLecture) {
        guard let theme = theme else { return }
        let color = lecture.getColor(theme: theme)
        setColor(color: color)
    }

    func setText() {
        var text = NSMutableAttributedString()
        if let lecture = lecture {
            let font = UIFont.systemFont(ofSize: 10.0)
            text.append(NSAttributedString(string: lecture.titleBreakLine, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font])))
        }
        if let singleClass = singleClass {
            let placeText = singleClass.place
            var size: CGFloat = 11.0
            if isLargerThanSE() {
                if placeText.characters.count >= 8 {
                    size = 10.0
                } else {
                    size = 11.0
                }
            } else {
                if placeText.characters.count >= 8 {
                    size = 9.0
                } else {
                    size = 10.0
                }
            }
            let font = UIFont.boldSystemFont(ofSize: size)
            if text.length != 0, singleClass.place != "" {
                text.append(NSAttributedString(string: "\n"))
            }
            if singleClass.place != "" {
                text.append(NSAttributedString(string: singleClass.placeBreakLine, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font])))
            }
        }
        courseText.attributedText = text
        courseText.baselineAdjustment = .alignCenters
    }

    func setColor() {
        guard let theme = theme else { return }
        let color = lecture.getColor(theme: theme)
        setColor(color: color)
    }

    func setColor(color: STColor) {
        backgroundColor = UIColor(hexString: color.bgColor.toHexString())
        courseText.textColor = UIColor(hexString: color.fgColor.toHexString())
    }

    func alertView(_: UIAlertView, clickedButtonAt _: Int) {
        /* //DEBUG
         if(buttonIndex == 1) {
             STCourseBooksManager.sharedInstance.currentCourseBook?.deleteLecture(singleClass!.lecture!)
         }
         */
    }

    @objc func longClick(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            longClicked?(self)
        }
    }

    @objc func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.recognized {
            tapped?(self)
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // no resizing
        return layoutAttributes
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value) })
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
