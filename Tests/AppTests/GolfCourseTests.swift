@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class GolfCourseTests: XCTestCase {
    
    let golfCoursesName = "Coyote Creek Golf Course"
    let golfCoursesStreetAddress = "1 Golf Way"
    let golfCoursesCity = "San Jose"
    let golfCoursesState = "California"
    let golfCoursesCountry = "United States"
    let golfCoursesPhoneNumber = "408-000-0000"
    
    let golfCoursesURI = "/api/golfcourses/"
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
    
    func getGolfCourse() throws -> GolfCourse {
        return try GolfCourse.create(name: golfCoursesName,
                                     streetAddress: golfCoursesStreetAddress,
                                     city: golfCoursesCity,
                                     state: golfCoursesState,
                                     country: golfCoursesCountry,
                                     phoneNumber: golfCoursesPhoneNumber,
                                     on: conn)
    }
    
    func testGolfCoursesCanBeRetrievedFromAPI() throws {
        let golfCourse = try getGolfCourse()
        _ = try GolfCourse.create(on: conn)
        let golfCourses = try app.getResponse(to: golfCoursesURI,
                                             decodeTo: [GolfCourse].self)
        XCTAssertEqual(golfCourses.count, 2)
        XCTAssertEqual(golfCourses[0].name, golfCoursesName)
        XCTAssertEqual(golfCourses[0].streetAddress, golfCoursesStreetAddress)
        XCTAssertEqual(golfCourses[0].city, golfCoursesCity)
        XCTAssertEqual(golfCourses[0].state, golfCoursesState)
        XCTAssertEqual(golfCourses[0].country, golfCoursesCountry)
        XCTAssertEqual(golfCourses[0].phoneNumber, golfCoursesPhoneNumber)
        XCTAssertEqual(golfCourses[0].id, golfCourse.id)
    }
    
    func testGolfCourseCanBeSavedWithAPI() throws {
        let golfCourse = GolfCourse(name: golfCoursesName,
                                    streetAddress: golfCoursesStreetAddress,
                                    city: golfCoursesCity,
                                    state: golfCoursesState,
                                    country: golfCoursesCountry,
                                    phoneNumber: golfCoursesPhoneNumber)
        let receivedGolfCourse = try app.getResponse(
            to: golfCoursesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: golfCourse,
            decodeTo: GolfCourse.self,
            loggedInRequest: true)
        XCTAssertEqual(golfCourse.name, receivedGolfCourse.name)
        XCTAssertEqual(golfCourse.streetAddress, receivedGolfCourse.streetAddress)
        XCTAssertEqual(golfCourse.city, receivedGolfCourse.city)
        XCTAssertEqual(golfCourse.state, receivedGolfCourse.state)
        XCTAssertEqual(golfCourse.country, receivedGolfCourse.country)
        XCTAssertEqual(golfCourse.phoneNumber, receivedGolfCourse.phoneNumber)
        
        let golfCourses = try app.getResponse(to: golfCoursesURI,
                                              decodeTo: [GolfCourse].self)
        XCTAssertEqual(golfCourses.count, 1)
        XCTAssertEqual(golfCourses[0].name, golfCoursesName)
        XCTAssertEqual(golfCourses[0].streetAddress, golfCoursesStreetAddress)
        XCTAssertEqual(golfCourses[0].city, golfCoursesCity)
        XCTAssertEqual(golfCourses[0].state, golfCoursesState)
        XCTAssertEqual(golfCourses[0].country, golfCoursesCountry)
        XCTAssertEqual(golfCourses[0].phoneNumber, golfCoursesPhoneNumber)
        XCTAssertEqual(golfCourses[0].id, receivedGolfCourse.id)
    }
    
    func testGettingASingleGolfCourseFromAPI() throws {
        let golfCourse = try getGolfCourse()
        let receivedGolfCourse = try app.getResponse(
            to: "\(golfCoursesURI)\(golfCourse.id!)",
            decodeTo: GolfCourse.self)
        XCTAssertEqual(golfCourse.name, receivedGolfCourse.name)
        XCTAssertEqual(golfCourse.streetAddress, receivedGolfCourse.streetAddress)
        XCTAssertEqual(golfCourse.city, receivedGolfCourse.city)
        XCTAssertEqual(golfCourse.state, receivedGolfCourse.state)
        XCTAssertEqual(golfCourse.country, receivedGolfCourse.country)
        XCTAssertEqual(golfCourse.phoneNumber, receivedGolfCourse.phoneNumber)
        XCTAssertEqual(golfCourse.id, receivedGolfCourse.id)
    }

    func testGettingAGolfCoursesTeesFromAPI() throws {
        let golfCourse = try getGolfCourse()
        let tee = try Tee.create(name: "Championship",
                                 golfCourse: golfCourse,
                                 on: conn)
        _ = try Tee.create(golfCourse: golfCourse,
                           on: conn)
        let tees = try app.getResponse(
            to: "\(golfCoursesURI)\(golfCourse.id!)/tees/",
            decodeTo: [Tee].self)
        XCTAssertEqual(tees.count, 2)
        XCTAssertEqual(tees[0].name, "Championship")
        XCTAssertEqual(tees[0].id, tee.id)
        XCTAssertEqual(tees[0].golfCourseID, golfCourse.id)
    }
    
    func testDeletingAGolfCourseFromAPI() throws {
        let golfCourse = try getGolfCourse()
        let receivedStatus = try app.getResponseStatus(
            to: "\(golfCoursesURI)\(golfCourse.id!)",
            method: .DELETE,
            loggedInRequest: true)
        XCTAssertNotEqual(receivedStatus, .notFound)
        XCTAssertEqual(receivedStatus, .noContent)
    }
    
    func testUpdatingAGolfCourseWithAPI() throws {
        let golfCourse = try getGolfCourse()
        golfCourse.name += "2"
        let receivedGolfCourse = try app.getResponse(
            to: "\(golfCoursesURI)\(golfCourse.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: golfCourse,
            decodeTo: GolfCourse.self,
            loggedInRequest: true)
        XCTAssertEqual(receivedGolfCourse.name, golfCoursesName + "2")
        XCTAssertEqual(receivedGolfCourse.streetAddress, golfCoursesStreetAddress)
        XCTAssertEqual(receivedGolfCourse.city, golfCoursesCity)
        XCTAssertEqual(receivedGolfCourse.state, golfCoursesState)
        XCTAssertEqual(receivedGolfCourse.country, golfCoursesCountry)
        XCTAssertEqual(receivedGolfCourse.phoneNumber, golfCoursesPhoneNumber)
        XCTAssertEqual(receivedGolfCourse.id, golfCourse.id)
    }
    
    static let allTests = [
        ("testGolfCoursesCanBeRetrievedFromAPI",
         testGolfCoursesCanBeRetrievedFromAPI),
        ("testGolfCourseCanBeSavedWithAPI",
         testGolfCourseCanBeSavedWithAPI),
        ("testGettingASingleGolfCourseFromAPI",
         testGettingASingleGolfCourseFromAPI),
        ("testGettingAGolfCoursesTeesFromAPI",
         testGettingAGolfCoursesTeesFromAPI),
        ("testDeletingAGolfCourseFromAPI",
         testDeletingAGolfCourseFromAPI),
        ("testUpdatingAGolfCourseWithAPI",
         testUpdatingAGolfCourseWithAPI)
    ]
}
