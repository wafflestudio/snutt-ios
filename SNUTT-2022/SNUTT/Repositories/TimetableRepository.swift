//
//  TimetableRepository.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/07.
//

import Foundation
import Alamofire

protocol TimetableRepositoryProtocol {
    func fetchRecentTimetable() async throws -> TimetableDto
}

class TimetableRepository: TimetableRepositoryProtocol {
    private let session: Session
    
    init(interceptor: RequestInterceptor, eventMonitors: [EventMonitor]) {
        session = Session(interceptor: interceptor, eventMonitors: eventMonitors)
    }
    
    func fetchRecentTimetable() async throws -> TimetableDto {
        let data = try await session.request(TimetableRouter.getRecentTimetable).validate().serializingDecodable(TimetableDto.self).value
            
        return data
    }
}
