//
//  STUtil.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STUtil {
    static func getRangeFromNSRange(_ string: String, range: NSRange) -> Range<String.Index> {
        let startIndex = string.characters.index(string.startIndex, offsetBy: range.location)
        let endIndex = string.characters.index(startIndex, offsetBy: range.length)
        return (startIndex ..< endIndex)
    }

    static func validateEmail(_ candidate: String) -> Bool {
        // from http://emailregex.com
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }

    static func validatePassword(_ password: String) -> Bool {
        if let _ = password.range(of: "^(?=.*\\d)(?=.*[a-z])\\S{6,20}$", options: [.regularExpression, .caseInsensitive]) {
            return true
        }
        return false
    }

    static func validateId(_ id: String) -> Bool {
        if let _ = id.range(of: "^[a-z0-9]{4,32}$", options: [.regularExpression, .caseInsensitive]) {
            return true
        }
        return false
    }

    static func isEmptyOrNil(str: String?) -> Bool {
        return str == nil || str == ""
    }
}

extension String {
    func localizedString() -> String {
        return NSLocalizedString(self, comment: "")
    }

    var breakOnlyAtNewLineAndSpace: String {
        let sc: Character = "\u{FEFF}"
        var tmp: [Character] = []
        var flag = false
        for (index, ch) in characters.enumerated() {
            if ch == "\n" || ch == " " {
                flag = true
                tmp.append(ch)
            } else {
                if flag || index == 0 {
                    flag = false
                } else {
                    tmp.append(sc)
                }
                tmp.append(ch)
            }
        }
        return String(tmp)
    }

    func trunc(length: Int, trailing: String? = "...") -> String {
        if characters.count > length {
            return substring(to: index(startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }

    func isEnglish() -> Bool {
        let characterSet = CharacterSet.alphanumerics.inverted
        return (rangeOfCharacter(from: characterSet) != nil)
    }

    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func roundCorner(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func setBottomBorder(_ color: UIColor, width: Double) {
        let border = CALayer()
        let width = CGFloat(width)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - width, width: frame.size.width, height: frame.size.height)

        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }

    func mask(_ rect: CGRect) {
        let maskLayer = CAShapeLayer()
        let path = CGPath(rect: rect, transform: nil)
        maskLayer.path = path
        layer.mask = maskLayer
    }
}

extension UIViewController {
    /// `child`를 `self`의 자식 뷰 컨트롤러로 추가한다.
    func add(childVC: UIViewController, animate: Bool = true, then: @escaping () -> Void) {
        childVC.view.alpha = 0

        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)

        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: []) {
            childVC.view.alpha = 1
        } completion: { _ in
            then()
        }
    }

    /// 부모 뷰 컨트롤러로부터 `self`를 제거한다.
    func remove(animate: Bool = true, then: @escaping () -> Void) {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }
        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, options: [.transitionCrossDissolve]) {
            self.view.alpha = 0
        } completion: { _ in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            then()
        }
    }
}

// Protocol for nscoding with struct in swift, source : http://redqueencoder.com/property-lists-and-user-defaults-in-swift/

protocol DictionaryRepresentable {
    func dictionaryValue() -> NSDictionary
    init?(dictionary: NSDictionary?)
}

extension RawRepresentable {
    init?(raw: Self.RawValue?) {
        if let rawValue = raw {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }
}

extension Array where Element: DictionaryRepresentable {
    func dictionaryValue() -> [NSDictionary] {
        let representation: [NSDictionary] = map { $0.dictionaryValue() }
        return representation
    }

    init?(dictionary: [NSDictionary]?) {
        guard let values = dictionary else { return nil }
        var testArray: [Element?] = values.map { Element(dictionary: $0) }
        let rawArray = testArray.compactMap { $0 }
        if testArray.count != rawArray.count {
            return nil
        }
        self = rawArray
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

func isLargerThanSE() -> Bool {
    return UIScreen.main.bounds.height > 700
}

extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }

    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }

    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }

    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }

    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }

    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }

    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }

    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date) > 0 { return "\(yearsFrom(date))년전" }
        if monthsFrom(date) > 0 { return "\(monthsFrom(date))달전" }
        if daysFrom(date) > 0 { return "\(daysFrom(date))일전" }
        if hoursFrom(date) > 0 { return "\(hoursFrom(date))시간전" }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))분전" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))초전" }
        return ""
    }

    func convertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let data = dateFormatter.string(from: self)
        return data
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UITextField {
    // This is for korean in textfield with no textborder bug
    // link : https://stackoverflow.com/questions/39556087/uitextfield-chinese-character-moves-down-when-editing-in-ios-10

    @IBInspectable var hideBorder: Bool {
        get {
            return borderStyle == UITextField.BorderStyle.none
        }
        set {
            if newValue {
                borderStyle = UITextField.BorderStyle.line
                borderStyle = UITextField.BorderStyle.none
            }
        }
    }
}

extension Collection {
    func get(_ index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
