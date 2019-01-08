@testable import App
import FluentPostgreSQL

extension Golfer {
    static func create(firstName: String = "Kevin",
                       lastName: String = "Schlaff",
                       age: Int = 24,
                       gender: String = "male",
                       weight: Int = 160,
                       on connection: PostgreSQLConnection)
        throws -> Golfer {
            let golfer = Golfer(firstName: firstName,
                                lastName: lastName,
                                age: age,
                                gender: gender,
                                weight: weight)
            return try golfer.save(on: connection).wait()
    }
}

extension GolfCourse {
    static func create(name: String = "Coyote Creek Golf Course",
                       streetAddress: String = "1 Golf Way",
                       city: String = "San Jose",
                       state: String = "California",
                       phoneNumber: String = "(408) 000-0000",
                       on connection: PostgreSQLConnection) throws -> GolfCourse {
        let golfCourse = GolfCourse(name: name,
                                    streetAddress: streetAddress,
                                    city: city,
                                    state: state,
                                    phoneNumber: phoneNumber)
        return try golfCourse.save(on: connection).wait()
        
    }
}

extension Hole {
    static func create(holeNumber: Int = 0,
                       tee: String = "",
                       par: Int = 0,
                       handicap:Int = 0,
                       yardage: Int = 0,
                       scorecard: Scorecard? = nil,
                       on connection: PostgreSQLConnection) throws -> Hole {
        var holeScorecard = scorecard
        if holeScorecard == nil {
            holeScorecard = try Scorecard
                .create(on: connection)
        }
        
        let hole = Hole(holeNumber: holeNumber,
                        tee: tee,
                        par: par,
                        handicap: handicap,
                        yardage: yardage,
                        scorecardID: holeScorecard!.id!)
        return try hole.save(on: connection).wait()
    }
}

extension Scorecard {
    static func create(tees: [String] = [String](),
                       golfCourse: GolfCourse? = nil,
                       on connection: PostgreSQLConnection) throws -> Scorecard {
        var scorecardGolfCourse = golfCourse
        if scorecardGolfCourse == nil {
            scorecardGolfCourse = try GolfCourse
                .create(on: connection)
        }
            
        let scorecard = Scorecard(tees: tees,
                                  golfCourseID: scorecardGolfCourse!.id!)
        return try scorecard.save(on: connection).wait()
    }
}

extension Score {
    static func create(date: Date = Date(),
                       strokesPerHole: [Int] = [Int](),
                       puttsPerHole: [Int] = [Int](),
                       greensInRegulation: [Bool] = [Bool](),
                       golfer: Golfer? = nil,
                       scorecard: Scorecard? = nil,
                       on connection: PostgreSQLConnection) throws -> Score {
        var scoreGolfer = golfer
        if scoreGolfer == nil {
            scoreGolfer = try Golfer.create(on: connection)
        }
        var scoreScorecard = scorecard
        if scoreScorecard == nil {
            scoreScorecard = try Scorecard.create(on: connection)
        }
        
        let score = Score(date: date,
                          strokesPerHole: strokesPerHole,
                          puttsPerHole: puttsPerHole,
                          greensInRegulation: greensInRegulation,
                          golferID: scoreGolfer!.id!,
                          scorecardID: scoreScorecard!.id!)
        return try score.save(on: connection).wait()
    }
}
