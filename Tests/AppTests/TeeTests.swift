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
        
    }
    
    func testSavingATeeWithAPI() throws {
        
    }
    
    func testGettingASingleTeeFromAPI() throws {
        
    }
    
    func testGettingATeesGolfCourseFromAPI() throws {
        
    }
    
    func testDeletingATeeFromAPI() throws {
        
    }
    
    func testUpdatingATeeWithAPI() throws {
        
    }

    static let allTests = [
        ("testTeesCanBeRetrievedWithAPI",
         testTeesCanBeRetrievedFromAPI),
        ("testSavingATeeWithAPI",
         testSavingATeeWithAPI),
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
