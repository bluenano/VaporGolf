@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class GolferTests: XCTestCase {
    
    let golfersFirstName = "Steve"
    let golfersLastName = "Stricker"
    let golfersAge = 45
    let golfersGender = "male"
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
        return try Golfer.create(firstName: golfersFirstName,
                                 lastName: golfersLastName,
                                 age: golfersAge,
                                 gender: golfersGender,
                                 weight: golfersWeight,
                                 on: conn)
    }
    // test that all golfers can be retrieved from the API
    func testGolfersCanBeRetrievedFromAPI() throws {
        let golfer = try getGolfer()
        _ = try Golfer.create(on: conn)
        let golfers = try app.getResponse(
            to: golfersURI,
            decodeTo: [Golfer].self)
        
        XCTAssertEqual(golfers.count, 2)
        XCTAssertEqual(golfers[0].firstName, golfersFirstName)
        XCTAssertEqual(golfers[0].lastName, golfersLastName)
        XCTAssertEqual(golfers[0].age, golfersAge)
        XCTAssertEqual(golfers[0].gender, golfersGender)
        XCTAssertEqual(golfers[0].weight, golfersWeight)
        XCTAssertEqual(golfers[0].id, golfer.id)
    }
 
    // test that a golfer can be saved to the API
    func testGolferCanBeSavedWithAPI() throws {
        let golfer = try getGolfer()
        let receivedGolfer = try app.getResponse(
            to: golfersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: golfer,
            decodeTo: Golfer.self)
        XCTAssertEqual(receivedGolfer.firstName, golfersFirstName)
        XCTAssertEqual(receivedGolfer.lastName, golfersLastName)
        XCTAssertEqual(receivedGolfer.age, golfersAge)
        XCTAssertEqual(receivedGolfer.gender, golfersGender)
        XCTAssertEqual(receivedGolfer.weight, golfersWeight)
        XCTAssertEqual(receivedGolfer.id, golfer.id)
        
        let golfers = try app.getResponse(to: golfersURI,
                                          decodeTo: [Golfer].self)
        XCTAssertEqual(golfers.count, 1)
        XCTAssertEqual(golfers[0].firstName, golfersFirstName)
        XCTAssertEqual(golfers[0].lastName, golfersLastName)
        XCTAssertEqual(golfers[0].age, golfersAge)
        XCTAssertEqual(golfers[0].gender, golfersGender)
        XCTAssertEqual(golfers[0].weight, golfersWeight)
        XCTAssertEqual(golfers[0].id, receivedGolfer.id)
    }
    
    // test that a single golfer can be retrieved from the API
    func testGettingASingleGolferFromAPI() throws {
        let golfer = try getGolfer()
        let receivedGolfer = try app.getResponse(
            to: "\(golfersURI)\(golfer.id!)",
            decodeTo: Golfer.self)
        XCTAssertEqual(golfer.firstName, receivedGolfer.firstName)
        XCTAssertEqual(golfer.lastName, receivedGolfer.lastName)
        XCTAssertEqual(golfer.age, receivedGolfer.age)
        XCTAssertEqual(golfer.gender, receivedGolfer.gender)
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
        
    }
    
    func testUpdatingAGolferWithAPI() throws {
        
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

