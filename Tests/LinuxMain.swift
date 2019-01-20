import XCTest

@testable import AppTests

XCTMain([
    testCase(GolferTests.allTests),
    testCase(GolfCourseTests.allTests),
    testCase(TeeTests.allTests),
    testCase(HoleTests.allTests),
    testCase(ScoreTests.allTests),
    testCase(ScoreImageTests.allTests)
])
