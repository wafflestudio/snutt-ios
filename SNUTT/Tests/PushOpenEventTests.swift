import Foundation
import Testing

@testable import SNUTT

struct PushOpenEventTests {
    @Test(arguments: [
        ("snutt://diary?lectureId=1&courseTitle=자료구조", "diary"),
        ("snutt://timetable-lecture?timetableId=1", "timetable-lecture"),
        ("https://host/a/b/?x=1#y", "host/a/b"),
        ("snutt://", nil),
    ] as [(String, String?)])
    func extractPathDropsQuery(urlScheme: String, expected: String?) {
        #expect(PushOpenEvent.extractPath(from: urlScheme) == expected)
    }

    @Test func parametersOmitMissingValues() {
        let event = PushOpenEvent(userInfo: ["push_id": "", "url_scheme": "snutt://diary?lectureId=1"])
        #expect(event.eventName == "push_open")
        #expect(event.parameters == ["path": "diary"])
    }

    @Test func parametersIncludePushID() {
        let event = PushOpenEvent(userInfo: ["push_id": "abc"])
        #expect(event.parameters == ["push_id": "abc"])
    }
}
