//
//  STTag.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STTagType : String {
    case Classification = "classification"
    case Department = "department"
    case AcademicYear = "academic_year"
    case Credit = "credit"
    case Instructor = "instructor"
    case Category = "category"
    
    var tagColor: UIColor {
        switch self {
        case .AcademicYear: return UIColor(hexString: "#dc2f45")
        case .Classification: return UIColor(hexString: "#e5731c")
        case .Credit: return UIColor(hexString: "#8bbb1a")
        case .Department: return UIColor(hexString: "#0cada6")
        case .Instructor: return UIColor(hexString: "#0d82cd")
        case .Category: return UIColor(hexString: "#9c45a0")
        }
    }
    
    var tagLightColor: UIColor {
        switch self {
        case .AcademicYear: return UIColor(hexString: "#e54459")
        case .Classification: return UIColor(hexString: "#f58d3d")
        case .Credit: return UIColor(hexString: "#a6d930")
        case .Department: return UIColor(hexString: "#1bd0c9")
        case .Instructor: return UIColor(hexString: "#1d99e9")
        case .Category: return UIColor(hexString: "#af56b3")
        }
    }
    
    var typeStr: String {
        switch self {
        case .AcademicYear: return "학년"
        case .Classification: return "분류"
        case .Credit: return "학점"
        case .Department: return "학과"
        case .Instructor: return "교수"
        case .Category: return "교양분류"
        }
    }
}

struct STTag : DictionaryRepresentable {
    var type : STTagType
    var text : String
    init(type: STTagType, text: String) {
        self.type = type
        self.text = text
    }
    
    //MARK: DictionaryRepresentable
    
    func dictionaryValue() -> NSDictionary {
        let representation : [String: Any] = ["type": type.rawValue, "text": text]
        return representation as NSDictionary
    }
    init?(dictionary: NSDictionary?) {
        guard let values = dictionary else {return nil}
        if let type = STTagType(raw: values["type"] as? String),
            let text = values["text"] as? String {
                    self.type = type
                    self.text = text
        } else {
            return nil
        }
    }
    
}

extension STTag : Equatable {
    public static func ==(lhs: STTag, rhs: STTag) -> Bool {
        return lhs.type == rhs.type && lhs.text == rhs.text
    }
}
