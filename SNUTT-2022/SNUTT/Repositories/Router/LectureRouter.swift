//
//  LectureRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/19.
//

import Foundation
import Alamofire

enum LectureRouter: Router {
    var baseURL: URL { return URL(string: "https://snutt-api-dev.wafflestudio.com" + "/tables")! }
    static let shouldAddToken: Bool = true

    case addCustomLecture(timetableId: String, lecture: LectureDto)
    case addLecture(timetableId: String, lectureId: String)
    case deleteLecture(timetableId: String, lecture: LectureDto)
    case updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto)
    case resetLecture(timetableId: String, lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .addCustomLecture:
            return .post
        case .addLecture:
            return .post
        case .deleteLecture:
            return .delete
        case .updateLecture, .resetLecture:
            return .put
        }
    }

    var path: String {
        switch self {
        case let .addCustomLecture(timetableId, _):
            return "/\(timetableId)/lecture"
        case let .addLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)"
        case let .deleteLecture(timetableId, lecture):
            return "/\(timetableId)/lecture/\(lecture._id)"
        case let .updateLecture(timetableId, curLecture, _):
            return "/\(timetableId)/lecture/\(curLecture._id)"
        case let .resetLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reset"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .addCustomLecture(_, lecture):
            return lecture.asDictionary()
        case .addLecture:
            return nil
        case .deleteLecture:
            return nil
        case let .updateLecture(_, oldLecture, newLecture):
            return oldLecture.extractModified(in: newLecture)
        case .resetLecture:
            return nil
        }
    }
}

extension Encodable {
    public func asJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    public func asDictionary() -> [String: AnyHashable]? {
        guard let data = self.asJSONData() else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyHashable] }
    }
    
    /// Compare two instances of `Encodable`, and extract any key-value pairs that is modified in `newData`.
    public func extractModified(in newData: Encodable) -> [String: Any] {
        var ret: [String: Any] = [:]
        guard let oldDict = self.asDictionary() else { return ret }
        guard let newDict = newData.asDictionary() else { return ret }
        for (key, newVal) in newDict {
            guard let oldVal = oldDict[key] else { continue }
            if oldVal != newVal {
                ret[key] = newVal
            }
        }
        for (key, oldVal) in oldDict {
            guard let newVal = newDict[key] else { continue }
            if oldVal != newVal {
                ret[key] = newVal
            }
        }
        return ret
    }
}

