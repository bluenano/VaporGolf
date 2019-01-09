@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class HoleTests: XCTestCase {
    
    let holeNumber = 1
    let holePar = 3
    let holeHandicap = 18
    let holeYardage = 205
    let tee = "Championship"
    
    let holesURI = "/api/holes/"
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
    
    func getHole() throws -> Hole {
        return try Hole.create(holeNumber: holeNumber,
                               tee: tee,
                               par: holePar,
                               handicap: holeHandicap,
                               yardage: holeYardage,
                               on: conn)
    }
    
    func testHolesCanBeRetrievedFromAPI() throws {
        let hole = try getHole()
        _ = try Hole.create(on: conn)
        let holes = try app.getResponse(to: holesURI,
                                        decodeTo: [Hole].self)
        XCTAssertEqual(holes.count, 2)
        XCTAssertEqual(holes[0].holeNumber, holeNumber)
        XCTAssertEqual(holes[0].tee, tee)
        XCTAssertEqual(holes[0].par, holePar)
        XCTAssertEqual(holes[0].yardage, holeYardage)
        XCTAssertEqual(holes[0].handicap, holeHandicap)
        XCTAssertEqual(holes[0].id, hole.id)
    }
    
    func testHoleCanBeSavedWithAPI() throws {
        let hole = try getHole()
        let receivedHole = try app.getResponse(
            to: holesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: hole,
            decodeTo: Hole.self)
        XCTAssertEqual(receivedHole.holeNumber, holeNumber)
        XCTAssertEqual(receivedHole.tee, tee)
        XCTAssertEqual(receivedHole.par, holePar)
        XCTAssertEqual(receivedHole.handicap, holeHandicap)
        XCTAssertEqual(receivedHole.yardage, holeYardage)
        XCTAssertEqual(receivedHole.id, hole.id)
        
        let holes = try app.getResponse(to: holesURI,
                                        decodeTo: [Hole].self)
        XCTAssertEqual(holes.count, 1)
        XCTAssertEqual(holes[0].holeNumber, holeNumber)
        XCTAssertEqual(holes[0].tee, tee)
        XCTAssertEqual(holes[0].par, holePar)
        XCTAssertEqual(holes[0].yardage, holeYardage)
        XCTAssertEqual(holes[0].handicap, holeHandicap)
        XCTAssertEqual(holes[0].id, receivedHole.id)
    }
    
    func testGettingASingleHoleFromAPI() throws {
        let hole = try getHole()
        let receivedHole = try app.getResponse(
            to: "\(holesURI)\(hole.id!)",
            decodeTo: Hole.self)
        XCTAssertEqual(receivedHole.holeNumber, holeNumber)
        XCTAssertEqual(receivedHole.tee, tee)
        XCTAssertEqual(receivedHole.par, holePar)
        XCTAssertEqual(receivedHole.handicap, holeHandicap)
        XCTAssertEqual(receivedHole.yardage, holeYardage)
        XCTAssertEqual(receivedHole.id, hole.id)
        
    }
    
    func testGettingAHolesScorecardFromAPI() throws {
        let scorecard = try Scorecard.create(
            tees: [String](repeating: "red", count: 1),
            on: conn)
        let hole = try Hole.create(holeNumber: 1,
                                   tee: scorecard.tees[0],
                                   par: 3,
                                   handicap: 18,
                                   yardage: 120,
                                   scorecard: scorecard,
                                   on: conn)
        
        let receivedScorecard = try app.getResponse(
            to: "\(holesURI)\(hole.id!)/scorecard/",
            decodeTo: Scorecard.self)
        XCTAssertEqual(receivedScorecard.tees, scorecard.tees)
        XCTAssertEqual(receivedScorecard.id, scorecard.id)
    }
    
    static let allTests = [
        ("testHolesCanBeRetrievedFromAPI",
         testHolesCanBeRetrievedFromAPI),
        ("testHoleCanBeSavedWithAPI",
         testHoleCanBeSavedWithAPI),
        ("testGettingASingleHoleFromAPI",
         testGettingASingleHoleFromAPI),
        ("testGettingAHolesScorecardFromAPI",
         testGettingAHolesScorecardFromAPI)
    ]
}
