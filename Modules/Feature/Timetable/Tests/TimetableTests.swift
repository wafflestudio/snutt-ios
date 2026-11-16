import Foundation
import Testing
import TimetableInterface

@Suite
struct SemesterTests {
    @Test func rawValuesMatchServerSemesterCodes() {
        #expect(Semester.first.rawValue == 1)
        #expect(Semester.summer.rawValue == 2)
        #expect(Semester.second.rawValue == 3)
        #expect(Semester.winter.rawValue == 4)
    }

    @Test(arguments: [
        ("SPRING", Semester.first),
        ("SUMMER", .summer),
        ("AUTUMN", .second),
        ("WINTER", .winter),
        ("autumn", .second),
    ])
    func deeplinkValueParsesSemesterNames(value: String, expected: Semester) {
        #expect(Semester(deeplinkValue: value) == expected)
    }

    @Test(arguments: [
        ("1", Semester.first),
        ("2", .summer),
        ("3", .second),
        ("4", .winter),
    ])
    func deeplinkValueParsesLegacyNumbers(value: String, expected: Semester) {
        #expect(Semester(deeplinkValue: value) == expected)
    }

    @Test(arguments: ["0", "5", "FALL", ""])
    func deeplinkValueRejectsUnknownValues(value: String) {
        #expect(Semester(deeplinkValue: value) == nil)
    }

    @Test func quartersSortInAcademicOrderWithinSameYear() {
        let quarters = [
            Quarter(year: 2026, semester: .winter),
            Quarter(year: 2026, semester: .summer),
            Quarter(year: 2026, semester: .second),
            Quarter(year: 2026, semester: .first),
        ].sorted()

        #expect(quarters.map(\.semester) == [.first, .summer, .second, .winter])
    }
}
