//
//  LectureRouter.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/19.
//

import Alamofire
import Foundation

enum LectureRouter: Router {
    var baseURL: URL { return URL(string: NetworkConfiguration.serverBaseURL + "/tables")! }
    static let shouldAddToken: Bool = true

    case addCustomLecture(timetableId: String, lecture: LectureDto, isForced: Bool)
    case addLecture(timetableId: String, lectureId: String, isForced: Bool)
    case deleteLecture(timetableId: String, lectureId: String)
    case updateLecture(timetableId: String, oldLecture: LectureDto, newLecture: LectureDto, isForced: Bool)
    case resetLecture(timetableId: String, lectureId: String)

    var method: HTTPMethod {
        switch self {
        case .addCustomLecture, .addLecture:
            return .post
        case .deleteLecture:
            return .delete
        case .updateLecture, .resetLecture:
            return .put
        }
    }

    var path: String {
        switch self {
        case let .addCustomLecture(timetableId, _, _):
            return "/\(timetableId)/lecture"
        case let .addLecture(timetableId, lectureId, _):
            return "/\(timetableId)/lecture/\(lectureId)"
        case let .deleteLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)"
        case let .updateLecture(timetableId, oldLecture, _, _):
            return "/\(timetableId)/lecture/\(oldLecture._id)"
        case let .resetLecture(timetableId, lectureId):
            return "/\(timetableId)/lecture/\(lectureId)/reset"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .addCustomLecture(_, lecture, isForced):
            var dict = lecture.asDictionary()
            dict?.removeValue(forKey: "_id")
            dict?["is_forced"] = isForced
            return dict
        case let .addLecture(_, _, isForced):
            return ["is_forced": isForced]
        case .deleteLecture:
            return nil
        case let .updateLecture(_, oldLecture, newLecture, isForced):
            var dict = oldLecture.extractModified(in: newLecture)
            dict["is_forced"] = isForced
            return dict
        case .resetLecture:
            return nil
        }
    }
}

public extension Encodable {
    func asJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    func asDictionary() -> [String: AnyHashable]? {
        guard let data = asJSONData() else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyHashable] }
    }

    /// Compare two instances of `Encodable`, and extract any key-value pairs that is modified in `newData`.
    func extractModified(in newData: Encodable) -> [String: Any] {
        var ret: [String: Any] = [:]
        guard let oldDict = asDictionary() else { return ret }
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
