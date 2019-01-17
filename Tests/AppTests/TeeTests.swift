@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class TeeTests: XCTestCase {
    
    let teeName = "Championship"
    
    let teesURI = "/api/tees/"
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
    
    func getTee() throws -> Tee {
        return try Tee.create(name: teeName,
                              on: conn)
    }
    
    func testTeesCanBeRetrievedFromAPI() throws {
        let tee = try getTee()
        _ = try Tee.create(on: conn)
        let tees = try app.getResponse(to: teesURI,
                                       decodeTo: [Tee].self)
        XCTAssertEqual(tees.count, 2)
        XCTAssertEqual(tees[0].name, teeName)
        XCTAssertEqual(tees[0].id, tee.id)
    }
    
    func testTeeCanBeSavedWithAPI() throws {
        let tee = try getTee()
        let receivedTee = try app.getResponse(
            to: teesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: tee,
            decodeTo: Tee.self)
        XCTAssertEqual(receivedTee.name, teeName)
        XCTAssertEqual(receivedTee.id, tee.id)
        
        let tees = try app.getResponse(to: teesURI,
                                       decodeTo: [Tee].self)
        XCTAssertEqual(tees.count, 1)
        XCTAssertEqual(tees[0].name, teeName)
        XCTAssertEqual(tees[0].id, tee.id)
    }
    
    func testGettingASingleTeeFromAPI() throws {
        let tee = try getTee()
        let receivedTee = try app.getResponse(
            to: "\(teesURI)\(tee.id!)",
            decodeTo: Tee.self)
        XCTAssertEqual(receivedTee.name, teeName)
        XCTAssertEqual(receivedTee.id, tee.id)
    }
    
    func testGettingATeesGolfCourseFromAPI() throws {
        let golfCourse = try GolfCourse.create(on: conn)
        let tee = try Tee.create(golfCourse: golfCourse,
                                 on: conn)
        let receivedGolfCourse = try app.getResponse(
            to: "\(teesURI)\(tee.id!)/golfcourse/",
            decodeTo: GolfCourse.self)
        XCTAssertEqual(receivedGolfCourse.name, golfCourse.name)
        XCTAssertEqual(receivedGolfCourse.streetAddress, golfCourse.streetAddress)
        XCTAssertEqual(receivedGolfCourse.city, golfCourse.city)
        XCTAssertEqual(receivedGolfCourse.state, golfCourse.state)
        XCTAssertEqual(receivedGolfCourse.phoneNumber, golfCourse.phoneNumber)
        XCTAssertEqual(receivedGolfCourse.id, golfCourse.id)
    }
    
    func testDeletingATeeFromAPI() throws {
        
    }
    
    func testUpdatingATeeWithAPI() throws {
        
    }

    static let allTests = [
        ("testTeesCanBeRetrievedWithAPI",
         testTeesCanBeRetrievedFromAPI),
        ("testTeeCanBeSavedWithAPI",
         testTeeCanBeSavedWithAPI),
        ("testGettingASingleTeeFromAPI",
         testGettingASingleTeeFromAPI),
        ("testGettingATeesGolfCourseFromAPI",
         testGettingATeesGolfCourseFromAPI),
        ("testDeletingATeeFromAPI",
         testDeletingATeeFromAPI),
        ("testUpdatingATeeFromAPI",
         testUpdatingATeeWithAPI)
    ]
}
