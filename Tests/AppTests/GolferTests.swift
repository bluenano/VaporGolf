@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class GolferTests: XCTestCase {
    
    let golfersUsername = "steve_stricker"
    let golfersFirstname = "Steve"
    let golfersLastname = "Stricker"
    let golfersAge = 45
    let golfersGender = "male"
    let golfersHeight = 80
    let golfersWeight = 180
    
    let golfersURI = "/api/golfers/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    // this code runs before each test
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    // this code runs after the tests
    override func tearDown() {
        conn.close()
    }
    
    func getGolfer() throws -> Golfer {
        return try Golfer.create(username: golfersUsername,
                                 firstname: golfersFirstname,
                                 lastname: golfersLastname,
                                 age: golfersAge,
                                 gender: golfersGender,
                                 height: golfersHeight,
                                 weight: golfersWeight,
                                 on: conn)
    }
    
    // test that all golfers can be retrieved from the API
    func testGolfersCanBeRetrievedFromAPI() throws {
        let golfer = try getGolfer()
        _ = try Golfer.create(on: conn)
        let golfers = try app.getResponse(
            to: golfersURI,
            decodeTo: [Golfer.Public].self)
        
        XCTAssertEqual(golfers.count, 3)
        XCTAssertEqual(golfers[1].username, golfersUsername)
        XCTAssertEqual(golfers[1].firstname, golfersFirstname)
        XCTAssertEqual(golfers[1].lastname, golfersLastname)
        XCTAssertEqual(golfers[1].age, golfersAge)
        XCTAssertEqual(golfers[1].gender, golfersGender)
        XCTAssertEqual(golfers[1].height, golfersHeight)
        XCTAssertEqual(golfers[1].weight, golfersWeight)
        XCTAssertEqual(golfers[1].id, golfer.id)
    }
 
    // test that a golfer can be saved to the API
    func testGolferCanBeSavedWithAPI() throws {
        let golfer = Golfer(username: golfersUsername,
                            password: "password",
                            firstname: golfersFirstname,
                            lastname: golfersLastname,
                            age: golfersAge,
                            gender: golfersGender,
                            height: golfersHeight,
                            weight: golfersWeight)
        let receivedGolfer = try app.getResponse(
            to: golfersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: golfer,
            decodeTo: Golfer.Public.self,
            loggedInRequest: true)
        XCTAssertEqual(receivedGolfer.username, golfersUsername)
        XCTAssertEqual(receivedGolfer.firstname, golfersFirstname)
        XCTAssertEqual(receivedGolfer.lastname, golfersLastname)
        XCTAssertEqual(receivedGolfer.age, golfersAge)
        XCTAssertEqual(receivedGolfer.gender, golfersGender)
        XCTAssertEqual(receivedGolfer.height, golfersHeight)
        XCTAssertEqual(receivedGolfer.weight, golfersWeight)
        
        let golfers = try app.getResponse(to: golfersURI,
                                          decodeTo: [Golfer.Public].self)
        XCTAssertEqual(golfers.count, 2)
        XCTAssertEqual(golfers[1].firstname, golfersFirstname)
        XCTAssertEqual(golfers[1].lastname, golfersLastname)
        XCTAssertEqual(golfers[1].age, golfersAge)
        XCTAssertEqual(golfers[1].gender, golfersGender)
        XCTAssertEqual(golfers[1].height, golfersHeight)
        XCTAssertEqual(golfers[1].weight, golfersWeight)
        XCTAssertEqual(golfers[1].id, receivedGolfer.id)
    }
    
    // test that a single golfer can be retrieved from the API
    func testGettingASingleGolferFromAPI() throws {
        let golfer = try getGolfer()
        let receivedGolfer = try app.getResponse(
            to: "\(golfersURI)\(golfer.id!)",
            decodeTo: Golfer.Public.self)
        XCTAssertEqual(golfer.username, receivedGolfer.username)
        XCTAssertEqual(golfer.firstname, receivedGolfer.firstname)
        XCTAssertEqual(golfer.lastname, receivedGolfer.lastname)
        XCTAssertEqual(golfer.age, receivedGolfer.age)
        XCTAssertEqual(golfer.gender, receivedGolfer.gender)
        XCTAssertEqual(golfer.height, receivedGolfer.height)
        XCTAssertEqual(golfer.weight, receivedGolfer.weight)
        XCTAssertEqual(golfer.id, receivedGolfer.id)
    }
    
    // test that all scores from a golfer can be retrieved from the API
    func testGettingAGolfersScoresFromAPI() throws {
        let golfer = try Golfer.create(on: conn)
        let tee = try Tee.create(on: conn)
        let strokes1 = [Int](repeating: 3, count: 18)
        let score1 = try Score.create(strokesPerHole: strokes1,
                                      golfer: golfer,
                                      tee: tee,
                                      on: conn)
        _ = try Score.create(golfer: golfer,
                             on: conn)
        
        let scores = try app.getResponse(to: "\(golfersURI)\(golfer.id!)/scores",
            decodeTo: [Score].self)
        XCTAssertEqual(scores.count, 2)
        XCTAssertEqual(scores[0].strokesPerHole, score1.strokesPerHole)
        XCTAssertEqual(scores[0].puttsPerHole, score1.puttsPerHole)
        XCTAssertEqual(scores[0].greensInRegulation, score1.greensInRegulation)
        XCTAssertEqual(scores[0].totalScore, score1.totalScore)
        XCTAssertEqual(scores[0].id, score1.id)
    }
    
    func testDeletingAGolferFromAPI() throws {
        let golfer = try getGolfer()
        let receivedStatus = try app.getResponseStatus(
            to: "\(golfersURI)\(golfer.id!)",
            method: .DELETE,
            loggedInRequest: true)
        XCTAssertNotEqual(receivedStatus, .notFound)
        XCTAssertEqual(receivedStatus, .noContent)
    }
    
    func testUpdatingAGolferWithAPI() throws {
        let golfer = try getGolfer()
        golfer.firstname = golfersFirstname + "2"
        let receivedGolfer = try app.getResponse(
            to: "\(golfersURI)\(golfer.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: golfer,
            decodeTo: Golfer.Public.self,
            loggedInUser: golfer)
        XCTAssertEqual(receivedGolfer.firstname, golfersFirstname + "2")
        XCTAssertEqual(receivedGolfer.lastname, golfersLastname)
        XCTAssertEqual(receivedGolfer.age, golfersAge)
        XCTAssertEqual(receivedGolfer.gender, golfersGender)
        XCTAssertEqual(receivedGolfer.height, golfersHeight)
        XCTAssertEqual(receivedGolfer.weight, golfersWeight)
        XCTAssertEqual(receivedGolfer.id, golfer.id)
    }
    
    static let allTests = [
        ("testGolfersCanBeRetrievedFromAPI",
         testGolfersCanBeRetrievedFromAPI),
        ("testGolferCanBeSavedWithAPI",
         testGolferCanBeSavedWithAPI),
        ("testGettingASingleGolferFromAPI",
         testGettingASingleGolferFromAPI),
        ("testGettingAGolfersScoresFromAPI",
         testGettingAGolfersScoresFromAPI),
        ("testDeletingAGolferFromAPI",
         testDeletingAGolferFromAPI),
        ("testUpdatingAGolferWithAPI",
         testUpdatingAGolferWithAPI)
    ]
}

