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
                       par: Int = 0,
                       handicap:Int = 0,
                       yardage: Int = 0,
                       tee: Tee? = nil,
                       on connection: PostgreSQLConnection) throws -> Hole {
        var holeTee = tee
        if holeTee == nil {
            holeTee = try Tee
                .create(on: connection)
        }
        
        let hole = Hole(holeNumber: holeNumber,
                        par: par,
                        handicap: handicap,
                        yardage: yardage,
                        teeID: holeTee!.id!)
        return try hole.save(on: connection).wait()
    }
}

extension Tee {
    static func create(name: String = "red",
                       golfCourse: GolfCourse? = nil,
                       on connection: PostgreSQLConnection) throws -> Tee {
        var teeGolfCourse = golfCourse
        if teeGolfCourse == nil {
            teeGolfCourse = try GolfCourse
                .create(on: connection)
        }
            
        let tee = Tee(name: name,
                      golfCourseID: teeGolfCourse!.id!)
        return try tee.save(on: connection).wait()
    }
}

extension Score {
    static func create(date: Date = Date(),
                       strokesPerHole: [Int] = [Int](),
                       puttsPerHole: [Int] = [Int](),
                       greensInRegulation: [Bool] = [Bool](),
                       golfer: Golfer? = nil,
                       tee: Tee? = nil,
                       on connection: PostgreSQLConnection) throws -> Score {
        var scoreGolfer = golfer
        if scoreGolfer == nil {
            scoreGolfer = try Golfer.create(on: connection)
        }
        var scoreTee = tee
        if scoreTee == nil {
            scoreTee = try Tee.create(on: connection)
        }

        let score = Score(date: date,
                          strokesPerHole: strokesPerHole,
                          puttsPerHole: puttsPerHole,
                          greensInRegulation: greensInRegulation,
                          golferID: scoreGolfer!.id!,
                          teeID: scoreTee!.id!)
        return try score.save(on: connection).wait()
    }
}

extension ScoreImage {
    static func create(imageData: File? = nil,
                       score: Score? = nil,
                       on connection: PostgreSQLConnection)
        throws -> ScoreImage {
            var scoreLocal = score
            if scoreLocal == nil {
                scoreLocal = try Score.create(on: connection)
            }
            let scoreImage = ScoreImage(imageData: imageData,
                                        scoreID: scoreLocal!.id!)
            return try scoreImage.save(on: connection).wait()
    }
    
    static func loadScoreImageFile(from filename: String)
        throws -> File? {
            let fileManager = FileManager.default
            let path = fileManager.currentDirectoryPath
            let targetPath = path + "/Images/" + filename
            if let nsData = NSData(contentsOfFile: targetPath) {
                return File(data: Data(referencing:nsData), filename: filename)
            }
            return nil
    }
}
