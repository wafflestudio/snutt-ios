//
//  Published+asBinding.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/27.
//

import SwiftUI


protocol Bindable {
    func asBinding(setter: @escaping (Self) -> Void) -> Binding<Self>
}

extension Bindable {
    
    func asBinding(setter: @escaping (Self) -> Void) -> Binding<Self> {
        return .init(get: { self }, set: setter)
    }
}

extension Bool: Bindable {}
extension String: Bindable {}
extension Lecture: Bindable {}

