@testable import App
import Vapor
import FluentPostgreSQL
import XCTest
import Foundation

final class ScoreImageTests: XCTestCase {
    
    let scoreImagesFileName = "EmptyScorecard.jpg"
    let scoreImagesSecondFileName = "EmptyScorecard2.jpg"
    var scoreImageFile: File!
    let scoreImagesURI = "/api/scoreimages/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
        scoreImageFile = try! ScoreImage.loadScoreImageFile(from: scoreImagesFileName)
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func getScoreImage() throws -> ScoreImage {
        return try ScoreImage.create(imageData: scoreImageFile,
                                     on: conn)
    }
    
    func testScoreImagesCanBeRetrievedFromAPI() throws {
        let scoreImage = try getScoreImage()
        _ = try ScoreImage.create(on: conn)
        let scoreImages = try app.getResponse(to: scoreImagesURI,
                                              decodeTo: [ScoreImage].self)
        XCTAssertEqual(scoreImages.count, 2)
        if let imageData = scoreImages[0].imageData {
            XCTAssertEqual(imageData.filename, scoreImagesFileName)
        }
        XCTAssertEqual(scoreImages[0].id, scoreImage.id)
    }
    
    func testScoreImageCanBeSavedWithAPI() throws {
        let scoreImage = try getScoreImage()
        let receivedScoreImage = try app.getResponse(
            to: scoreImagesURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: scoreImage,
            decodeTo: ScoreImage.self,
            loggedInRequest: true)
        if let imageData = receivedScoreImage.imageData {
            XCTAssertEqual(imageData.filename, scoreImagesFileName)
        }
        XCTAssertEqual(receivedScoreImage.id, scoreImage.id)
        let scoreImages = try app.getResponse(to: scoreImagesURI,
                                              decodeTo: [ScoreImage].self)
        XCTAssertEqual(scoreImages.count, 1)
        if let imageData = scoreImages[0].imageData {
            XCTAssertEqual(imageData.filename, scoreImagesFileName)
        }
        XCTAssertEqual(scoreImages[0].id, scoreImage.id)
    }
    
    func testGettingASingleScoreImageFromAPI() throws {
        let scoreImage = try getScoreImage()
        let receivedScoreImage = try app.getResponse(
            to: "\(scoreImagesURI)\(scoreImage.id!)",
            decodeTo: ScoreImage.self)
        if let imageData = receivedScoreImage.imageData {
            XCTAssertEqual(imageData.filename, scoreImagesFileName)
        }
        XCTAssertEqual(receivedScoreImage.id, scoreImage.id)
    }
    
    func testGettingAScoreImagesScoreFromAPI() throws {
        let score = try Score.create(date: Date(),
                                     strokesPerHole: [Int](repeating: 3, count: 18),
                                     puttsPerHole: [Int](repeating: 3, count: 18),
                                     greensInRegulation: [Bool](repeating: false, count: 18),
                                     on: conn)
        let scoreImage = try ScoreImage.create(imageData: scoreImageFile,
                                               score: score,
                                               on: conn)
        let receivedScore = try app.getResponse(
            to: "\(scoreImagesURI)\(scoreImage.id!)/score/",
            decodeTo: Score.self)

        for i in 0..<receivedScore.puttsPerHole.count {
            XCTAssertEqual(receivedScore.strokesPerHole[i], 3)
            XCTAssertEqual(receivedScore.puttsPerHole[i], 3)
            XCTAssertEqual(receivedScore.greensInRegulation[i], false)
        }
        XCTAssertEqual(receivedScore.strokesPerHole.count, 18)
        XCTAssertEqual(receivedScore.puttsPerHole.count, 18)
        XCTAssertEqual(receivedScore.greensInRegulation.count, 18)
        XCTAssertEqual(receivedScore.totalScore, 3 * 18)
        XCTAssertEqual(receivedScore.id, score.id)
    }
    
    func testDeletingAScoreImageFromAPI() throws {
        let scoreImage = try getScoreImage()
        let receivedStatus = try app.getResponseStatus(
            to: "\(scoreImagesURI)\(scoreImage.id!)",
            method: .DELETE,
            loggedInRequest: true)
        XCTAssertNotEqual(receivedStatus, .notFound)
        XCTAssertEqual(receivedStatus, .noContent)
    }
    
    func testUpdatingAScoreImageWithAPI() throws {
        let scoreImage = try getScoreImage()
        scoreImage.imageData = try ScoreImage.loadScoreImageFile(from: scoreImagesSecondFileName)
        let receivedScoreImage = try app.getResponse(
            to: "\(scoreImagesURI)\(scoreImage.id!)",
            method: .PUT,
            headers: ["Content-Type": "application/json"],
            data: scoreImage,
            decodeTo: ScoreImage.self,
            loggedInRequest: true)
        if let imageData = receivedScoreImage.imageData {
            XCTAssertEqual(imageData.filename, scoreImagesSecondFileName)
        }
        XCTAssertEqual(receivedScoreImage.id, scoreImage.id)
    }
    
    static let allTests = [
        ("testScoreImagesCanBeRetrievedFromAPI",
         testScoreImagesCanBeRetrievedFromAPI),
        ("testScoreImageCanBeSavedWithAPI",
         testScoreImageCanBeSavedWithAPI),
        ("testGettingASingleScoreImageFromAPI",
         testGettingASingleScoreImageFromAPI),
        ("testGettingAScoreImagesScoreFromAPI",
         testGettingAScoreImagesScoreFromAPI),
        ("testDeletingAScoreImageFromAPI",
         testDeletingAScoreImageFromAPI),
        ("testUpdatingAScoreImageFromAPI",
         testUpdatingAScoreImageWithAPI)
    ]
}
