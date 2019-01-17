@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class ScoreTests: XCTestCase {
    
    let scoreDate = Date()
    let strokesPerHole = [Int](repeating: 5, count: 18)
    let puttsPerHole = [Int](repeating: 2, count: 18)
    let greensInRegulation = [Bool](repeating: false, count: 18)
    
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
        XCTAssertEqual(receivedScore.id, score.id)
        
        let scores = try app.getResponse(to: scoresURI,
                                         decodeTo: [Score].self)
        
        XCTAssertEqual(scores.count, 1)
        //XCTAssertEqual(scores[0].date, scoreDate)
        XCTAssertEqual(scores[0].strokesPerHole, strokesPerHole)
        XCTAssertEqual(scores[0].puttsPerHole, puttsPerHole)
        XCTAssertEqual(scores[0].greensInRegulation, greensInRegulation)
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
    
    func testGettingAScoresTeeFromAPI() throws {
        let tee = try Tee.create(on: conn)
        let score = try Score.create(tee: tee,
                                     on: conn)
        let receivedTee = try app.getResponse(
            to:"\(scoresURI)\(score.id!)/tee/",
            decodeTo: Tee.self)
        XCTAssertEqual(receivedTee.name, tee.name)
        XCTAssertEqual(receivedTee.id, tee.id)
    }

    func testDeletingAScoreFromAPI() throws {
        let score = try getScore()
        let receivedStatus = try app.getResponseStatus(
            to: "\(scoresURI)\(score.id!)",
            method: .DELETE)
        XCTAssertNotEqual(receivedStatus, .notFound)
        XCTAssertEqual(receivedStatus, .noContent)

    }
    
    func testUpdatingAScoreWithAPI() throws {
        let score = try getScore()
        for i in 0..<score.strokesPerHole.count {
            score.strokesPerHole[i] += 1
        }
        let receivedScore = try app.getResponse(
            to: "\(scoresURI)\(score.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: score,
            decodeTo: Score.self)
        for i in 0..<receivedScore.strokesPerHole.count {
            XCTAssertEqual(receivedScore.strokesPerHole[i],
                           strokesPerHole[i]+1)
        }
        XCTAssertEqual(receivedScore.puttsPerHole, puttsPerHole)
        XCTAssertEqual(receivedScore.greensInRegulation, greensInRegulation)
        XCTAssertEqual(receivedScore.totalScore, score.totalScore)
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
        ("testGettingAScoresTeeFromAPI",
         testGettingAScoresTeeFromAPI),
        ("testDeletingAScoreFromAPI",
         testDeletingAScoreFromAPI),
        ("testUpdatingAScoreWithAPI",
         testUpdatingAScoreWithAPI)
    ]
}
