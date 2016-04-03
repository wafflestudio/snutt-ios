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
        let representation : [String: AnyObject] = ["type": type.rawValue, "text": text]
        return representation
    }
    init?(dictionary: NSDictionary?) {
        guard let values = dictionary else {return nil}
        if let  type = STTagType(raw: values["type"] as? String),
                text = values["text"] as? String {
                    self.type = type
                    self.text = text
        } else {
            return nil
        }
    }
    
}