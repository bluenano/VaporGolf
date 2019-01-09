import Vapor
import Fluent

struct ScorecardsController: RouteCollection {
    
    func boot(router: Router) throws {
        let scorecardsRoutes = router.grouped("api", "scorecards")
        scorecardsRoutes.post(Scorecard.self, use: createHandler)
        scorecardsRoutes.delete(Scorecard.parameter, use: deleteHandler)
        scorecardsRoutes.put(Scorecard.parameter, use: updateHandler)
        scorecardsRoutes.get(use: getAllHandler)
        scorecardsRoutes.get(Scorecard.parameter, use: getHandler)
        scorecardsRoutes.get("first", use: getFirstHandler)
        scorecardsRoutes.get(Scorecard.parameter, "golfcourse", use: getGolfCourseHandler)
        scorecardsRoutes.get(Scorecard.parameter, "holes", use: getHolesHandler)
        scorecardsRoutes.get(Scorecard.parameter, "scores", use: getScoresHandler)
    }

    func createHandler(_ req: Request,
                       scorecard: Scorecard) throws
        -> Future<Scorecard> {
            return scorecard.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Scorecard.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Scorecard> {
        return try flatMap(
            to: Scorecard.self,
            req.parameters.next(Scorecard.self),
            req.content.decode(Scorecard.self)) { scorecard, updatedScorecard in
                scorecard.tees = updatedScorecard.tees
                scorecard.golfCourseID = updatedScorecard.golfCourseID
                return scorecard.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Scorecard]> {
        return Scorecard.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Scorecard> {
        return try req.parameters.next(Scorecard.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Scorecard> {
        return Scorecard.query(on: req)
            .first()
            .map(to: Scorecard.self) { scorecard in
                guard let scorecard = scorecard else {
                    throw Abort(.notFound)
                }
                return scorecard
        }
    }
    
    func getGolfCourseHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try req.parameters
        .next(Scorecard.self)
            .flatMap(to: GolfCourse.self) {
                scorecard in scorecard.golfCourse.get(on: req)
        }
    }
    
    func getHolesHandler(_ req: Request) throws -> Future<[Hole]> {
        return try req
            .parameters.next(Scorecard.self)
            .flatMap(to: [Hole].self) { scorecard in
                try scorecard.holes.query(on: req).all()
        }
    }
    
    func getScoresHandler(_ req: Request) throws -> Future<[Score]> {
        return try req
        .parameters.next(Scorecard.self)
            .flatMap(to: [Score].self) { scorecard in
                try scorecard.scores.query(on: req).all()
        }
    }
    
}
