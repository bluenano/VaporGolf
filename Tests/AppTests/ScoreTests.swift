@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class ScoreTests: XCTestCase {
    
    let scoreDate = Date()
    let strokesPerHole = [Int](repeating: 5, count: 18)
    let puttsPerHole = [Int](repeating: 2, count: 18)
    let greensInRegulation = [Bool](repeating: false, count: 18)
    let scoreTee = "Championship"
    
    let scoresURI = "/api/scores/"
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
    
    func getScore() throws -> Score {
        return try Score.create(date: scoreDate,
                                strokesPerHole: strokesPerHole,
                                puttsPerHole: puttsPerHole,
                                greensInRegulation: greensInRegulation,
                                tee: scoreTee,
                                on: conn)
    }
    
    func testScoresCanBeRetrievedFromAPI() throws {
        let score = try getScore()
        _ = try Score.create(on: conn)
        
        let scores = try app.getResponse(to: scoresURI,
                                         decodeTo: [Score].self)
        
        XCTAssertEqual(scores.count, 2)
        //XCTAssertEqual(scores[0].date, scoreDate)
        XCTAssertEqual(scores[0].strokesPerHole, strokesPerHole)
        XCTAssertEqual(scores[0].puttsPerHole, puttsPerHole)
        XCTAssertEqual(scores[0].greensInRegulation, greensInRegulation)
        XCTAssertEqual(scores[0].tee, scoreTee)
        XCTAssertEqual(scores[0].id, score.id)
    }
    
    func testScoreCanBeSavedWithAPI() throws {
        let score = try getScore()
        
        let receivedScore = try app.getResponse(
            to: scoresURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: score,
            decodeTo: Score.self)
        
        //XCTAssertEqual(receivedScore.date, scoreDate)
        XCTAssertEqual(receivedScore.strokesPerHole, strokesPerHole)
        XCTAssertEqual(receivedScore.puttsPerHole, puttsPerHole)
        XCTAssertEqual(receivedScore.greensInRegulation, greensInRegulation)
        XCTAssertEqual(receivedScore.tee, scoreTee)
        XCTAssertEqual(receivedScore.id, score.id)
        
        let scores = try app.getResponse(to: scoresURI,
                                         decodeTo: [Score].self)
        
        XCTAssertEqual(scores.count, 1)
        //XCTAssertEqual(scores[0].date, scoreDate)
        XCTAssertEqual(scores[0].strokesPerHole, strokesPerHole)
        XCTAssertEqual(scores[0].puttsPerHole, puttsPerHole)
        XCTAssertEqual(scores[0].greensInRegulation, greensInRegulation)
        XCTAssertEqual(scores[0].tee, scoreTee)
        XCTAssertEqual(scores[0].id, score.id)
    }
    
    func testGettingASingleScoreFromAPI() throws {
        let score = try getScore()
        let receivedScore = try app.getResponse(
            to: "\(scoresURI)\(score.id!)",
            decodeTo: Score.self)
        
        //XCTAssertEqual(receivedScore.date, scoreDate)
        XCTAssertEqual(receivedScore.strokesPerHole, strokesPerHole)
        XCTAssertEqual(receivedScore.puttsPerHole, puttsPerHole)
        XCTAssertEqual(receivedScore.greensInRegulation, greensInRegulation)
        XCTAssertEqual(receivedScore.tee, scoreTee)
        XCTAssertEqual(receivedScore.id, score.id)
    }
    
    func testGettingAScoresGolferFromAPI() throws {
        let golfer = try Golfer.create(on: conn)
        let score = try Score.create(golfer: golfer, on: conn)
        let receivedGolfer = try app.getResponse(
            to: "\(scoresURI)\(score.id!)/golfer/",
            decodeTo: Golfer.self)
        XCTAssertEqual(receivedGolfer.firstName, golfer.firstName)
        XCTAssertEqual(receivedGolfer.lastName, golfer.lastName)
        XCTAssertEqual(receivedGolfer.age, golfer.age)
        XCTAssertEqual(receivedGolfer.gender, golfer.gender)
        XCTAssertEqual(receivedGolfer.weight, golfer.weight)
        XCTAssertEqual(receivedGolfer.id, golfer.id)
    }
    
    func testGettingAScoresScorecardFromAPI() throws {
        let scorecard = try Scorecard.create(on: conn)
        let score = try Score.create(scorecard: scorecard,
                                     on: conn)
        let receivedScorecard = try app.getResponse(
            to:"\(scoresURI)\(score.id!)/scorecard/",
            decodeTo: Scorecard.self)
        XCTAssertEqual(receivedScorecard.tees, scorecard.tees)
        XCTAssertEqual(receivedScorecard.id, scorecard.id)
    }

    static let allTests = [
        ("testScoresCanBeRetrievedFromAPI",
         testScoresCanBeRetrievedFromAPI),
        ("testScoreCanBeSavedWithAPI",
         testScoreCanBeSavedWithAPI),
        ("testGettingASingleScoreFromAPI",
         testGettingASingleScoreFromAPI),
        ("testGettingAScoresGolferFromAPI",
         testGettingAScoresGolferFromAPI),
        ("testGettingAScoresScorecardFromAPI",
         testGettingAScoresScorecardFromAPI)
    ]
}
