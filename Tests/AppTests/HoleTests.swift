@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class HoleTests: XCTestCase {
    
    let holeNumber = 1
    let holePar = 3
    let holeHandicap = 18
    let holeYardage = 205
    
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
            decodeTo: Hole.self,
            loggedInRequest: true)
        XCTAssertEqual(receivedHole.holeNumber, holeNumber)
        XCTAssertEqual(receivedHole.par, holePar)
        XCTAssertEqual(receivedHole.handicap, holeHandicap)
        XCTAssertEqual(receivedHole.yardage, holeYardage)
        XCTAssertEqual(receivedHole.id, hole.id)
        
        let holes = try app.getResponse(to: holesURI,
                                        decodeTo: [Hole].self,
                                        loggedInRequest: true)
        XCTAssertEqual(holes.count, 1)
        XCTAssertEqual(holes[0].holeNumber, holeNumber)
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
        XCTAssertEqual(receivedHole.par, holePar)
        XCTAssertEqual(receivedHole.handicap, holeHandicap)
        XCTAssertEqual(receivedHole.yardage, holeYardage)
        XCTAssertEqual(receivedHole.id, hole.id)
        
    }
    
    func testGettingAHolesTeeFromAPI() throws {
        let tee = try Tee.create(
            name: "Championship",
            on: conn)
        let hole = try Hole.create(holeNumber: 1,
                                   par: 3,
                                   handicap: 18,
                                   yardage: 120,
                                   tee: tee,
                                   on: conn)
        
        let receivedTee = try app.getResponse(
            to: "\(holesURI)\(hole.id!)/tee/",
            decodeTo: Tee.self)
        XCTAssertEqual(receivedTee.name, tee.name)
        XCTAssertEqual(receivedTee.id, tee.id)
    }
    
    func testDeletingAHoleFromAPI() throws {
        let hole = try getHole()
        let receivedStatus = try app.getResponseStatus(
            to: "\(holesURI)\(hole.id!)",
            method: .DELETE,
            loggedInRequest: true)
        XCTAssertNotEqual(receivedStatus, .notFound)
        XCTAssertEqual(receivedStatus, .noContent)
    }
    
    func testUpdatingAHoleWithAPI() throws {
        let hole = try getHole()
        hole.handicap = holeHandicap+1
        let receivedHole = try app.getResponse(
            to: "\(holesURI)\(hole.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: hole,
            decodeTo: Hole.self,
            loggedInRequest: true)
        XCTAssertEqual(receivedHole.holeNumber, holeNumber)
        XCTAssertEqual(receivedHole.par, holePar)
        XCTAssertEqual(receivedHole.handicap, holeHandicap+1)
        XCTAssertEqual(receivedHole.yardage, holeYardage)
        XCTAssertEqual(receivedHole.id, hole.id)
    }
    
    static let allTests = [
        ("testHolesCanBeRetrievedFromAPI",
         testHolesCanBeRetrievedFromAPI),
        ("testHoleCanBeSavedWithAPI",
         testHoleCanBeSavedWithAPI),
        ("testGettingASingleHoleFromAPI",
         testGettingASingleHoleFromAPI),
        ("testGettingAHolesTeeFromAPI",
         testGettingAHolesTeeFromAPI),
        ("testDeletingAHoleFromAPI",
         testDeletingAHoleFromAPI),
        ("testUpdatingAHoleWithAPI",
         testUpdatingAHoleWithAPI)
    ]
}
