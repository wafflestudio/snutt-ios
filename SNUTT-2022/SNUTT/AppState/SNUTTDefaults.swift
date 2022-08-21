//
//  SNUTTDefaults.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/04.
//

// import Foundation
// import SwiftUI
//
///// PropertyWrapper for easier use of UserDefaults
/////
///// `value` is used as initial value when there is no existing value for `key` in `UserDefaults`
///// ```
///// @SNUTTDefaults(SNUTTDefaultsContainer.DataType.example, value: 1) var exampleInt: Int?
///// ```
// @propertyWrapper
// struct SNUTTDefaults<Value: Codable> {
//    var key: String
//    var value: Value
//    private let storage: UserDefaults = .shared
//
//    init(_ data: SNUTTDefaultsContainer.DataType, value: Value) {
//        key = data.key
//        self.value = value
//    }
//
//    var wrappedValue: Value {
//        get {
//            guard let existing = storage.object(forKey: key) as? Data else {
//                return value
//            }
//            let decodedData = try? JSONDecoder().decode(Value.self, from: existing)
//            return decodedData ?? value
//        }
//        set {
//            let encodedData = try? JSONEncoder().encode(newValue)
//            storage.set(encodedData, forKey: key)
//        }
//    }
// }
