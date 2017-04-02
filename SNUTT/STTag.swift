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
        case .AcademicYear: return UIColor.flatSkyBlueDark
        case .Category: return UIColor.flatYellowDark
        case .Classification: return UIColor.flatGreenDark
        case .Credit: return UIColor.flatCoffeeDark
        case .Department: return UIColor.flatOrangeDark
        case .Instructor: return UIColor.flatWatermelonDark
        }
    }
    
    var tagLightColor: UIColor {
        switch self {
        case .AcademicYear: return UIColor.flatSkyBlue
        case .Category: return UIColor.flatYellow
        case .Classification: return UIColor.flatGreen
        case .Credit: return UIColor.flatCoffee
        case .Department: return UIColor.flatOrange
        case .Instructor: return UIColor.flatWatermelon
        }
    }
    
    var typeStr: String {
        switch self {
        case .AcademicYear: return "학년"
        case .Category: return "교양분류"
        case .Classification: return "분류"
        case .Credit: return "학점"
        case .Department: return "학과"
        case .Instructor: return "교수"
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
