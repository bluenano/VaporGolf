@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class ScorecardTests: XCTestCase {
    
    let scorecardTees = [String](repeating: "red", count: 3)
    
    let scorecardsURI = "/api/scorecards/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func getScorecard() throws -> Scorecard {
        return try Scorecard.create(tees: scorecardTees, on: conn)
    }
    
    func testGettingScorecardsFromAPI() throws {
        let scorecard = try getScorecard()
        _ = try Scorecard.create(on: conn)
        
        let scorecards = try app.getResponse(to: scorecardsURI,
                                             decodeTo: [Scorecard].self)
        XCTAssertEqual(scorecards.count, 2)
        XCTAssertEqual(scorecards[0].tees, scorecardTees)
        XCTAssertEqual(scorecards[0].id, scorecard.id)
    }
    
    func testScorecardCanBeSavedWithAPI() throws {
        let scorecard = try getScorecard()
        let receivedScorecard = try app.getResponse(
            to: scorecardsURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: scorecard,
            decodeTo: Scorecard.self)
        
        XCTAssertEqual(receivedScorecard.tees, scorecardTees)
        XCTAssertEqual(receivedScorecard.id, scorecard.id)
        
        let scorecards = try app.getResponse(to: scorecardsURI,
                                             decodeTo: [Scorecard].self)
        XCTAssertEqual(scorecards.count, 1)
        XCTAssertEqual(scorecards[0].tees, scorecardTees)
        XCTAssertEqual(scorecards[0].id, scorecard.id)
    }
    
    func testGettingASingleScorecardWithAPI() throws {
        let scorecard = try getScorecard()
        let receivedScorecard = try app.getResponse(
            to: "\(scorecardsURI)\(scorecard.id!)",
            decodeTo: Scorecard.self)
        XCTAssertEqual(receivedScorecard.tees, scorecardTees)
        XCTAssertEqual(receivedScorecard.id, scorecard.id)
    }
    
    func testGettingAScorecardsGolfCourseWithAPI() throws {
        let golfCourse = try GolfCourse.create(on: conn)
        let scorecard = try Scorecard.create(golfCourse: golfCourse,
                                             on: conn)
        let receivedGolfCourse = try app.getResponse(
            to: "\(scorecardsURI)\(scorecard.id!)/golfcourse/",
            decodeTo: GolfCourse.self)
        XCTAssertEqual(receivedGolfCourse.name, golfCourse.name)
        XCTAssertEqual(receivedGolfCourse.streetAddress, golfCourse.streetAddress)
        XCTAssertEqual(receivedGolfCourse.city, golfCourse.city)
        XCTAssertEqual(receivedGolfCourse.state, golfCourse.state)
        XCTAssertEqual(receivedGolfCourse.phoneNumber, golfCourse.phoneNumber)
        XCTAssertEqual(receivedGolfCourse.id, golfCourse.id)
    }
    
    func testGettingAScorecardsScoresWithAPI() throws {
        let scorecard = try getScorecard()
        let score1 = try Score.create(strokesPerHole: [Int](repeating: 5, count: 18),
                                      puttsPerHole: [Int](repeating: 2, count: 18),
                                      greensInRegulation: [Bool](repeating: false, count: 18),
                                      tee: "red",
                                      scorecard: scorecard,
                                      on: conn)
        _ = try Score.create(scorecard: scorecard,
                                      on: conn)
        let scores = try app.getResponse(to: "\(scorecardsURI)\(scorecard.id!)/scores/",
                                         decodeTo: [Score].self)
        XCTAssertEqual(scores.count, 2)
        XCTAssertEqual(scores[0].strokesPerHole, score1.strokesPerHole)
        XCTAssertEqual(scores[0].puttsPerHole, score1.puttsPerHole)
        XCTAssertEqual(scores[0].greensInRegulation, score1.greensInRegulation)
        XCTAssertEqual(scores[0].tee, score1.tee)
        XCTAssertEqual(scores[0].id, score1.id)
    }
    
    static let allTests = [
        ("testGettingScorecardsFromAPI",
         testGettingScorecardsFromAPI),
        ("testScorecardCanBeSavedWithAPI",
         testScorecardCanBeSavedWithAPI),
        ("testGettingASingleScorecardWithAPI",
         testGettingASingleScorecardWithAPI),
        ("testGettingAScorecardsGolfCourseWithAPI",
         testGettingAScorecardsGolfCourseWithAPI),
        ("testGettingAScorecardsScoresWithAPI",
         testGettingAScorecardsScoresWithAPI)
    ]
}
