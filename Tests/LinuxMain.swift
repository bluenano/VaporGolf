import XCTest

@testable import AppTests

XCTMain([
    testCase(GolferTests.allTests),
    testCase(GolfCourseTests.allTests),
    testCase(ScorecardTests.allTests),
    testCase(HoleTests.allTests),
    testCase(ScoreTests.allTests)
])
