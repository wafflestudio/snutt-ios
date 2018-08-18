//
//  CoreAssembly.swift
//  SNUTT
//
//  Created by Rajin on 2018. 8. 12..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Swinject

class CoreAssembly : Assembly {
    func assemble(container: Container) {
        container.register(STTimetableManager.self) { r in
            STTimetableManager()
        }
        container.register(STCourseBookListManager.self) { r in
            STCourseBookListManager()
        }
        container.register(STTagManager.self) { r in STTagManager(resolver: r) }
        container.register(STColorManager.self) { r in STColorManager() }
    }
}
