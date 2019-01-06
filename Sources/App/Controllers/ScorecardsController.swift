import Vapor
import Fluent

struct ScorecardsController: RouteCollection {
    
    func boot(router: Router) throws {
        let scorecardsRoutes = router.grouped("api", "scorecards")
        scorecardsRoutes.post(Scorecard.self, use: createHandler)
        scorecardsRoutes.delete(use: deleteHandler)
        scorecardsRoutes.put(use: updateHandler)
        scorecardsRoutes.get(use: getAllHandler)
        scorecardsRoutes.get(use: getHandler)
        scorecardsRoutes.get(use: getFirstHandler)
        scorecardsRoutes.get(Scorecard.parameter, "golfcourses", use: getGolfCourseHandler)
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
    
}
