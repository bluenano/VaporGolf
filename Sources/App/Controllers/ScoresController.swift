import Vapor
import Fluent

struct ScoresController: RouteCollection {
    
    func boot(router: Router) throws {
        let scoresRoutes = router.grouped("api", "scores")
        scoresRoutes.post(Score.self, use: createHandler)
        scoresRoutes.delete(Score.parameter, use: deleteHandler)
        scoresRoutes.put(Score.parameter, use: updateHandler)
        scoresRoutes.get(use: getAllHandler)
        scoresRoutes.get(Score.parameter, use: getHandler)
        scoresRoutes.get("first", use: getFirstHandler)
        scoresRoutes.get("search", use: getSearchHandler)
        scoresRoutes.get("sorted", use: getSortedHandler)
        scoresRoutes.get(Score.parameter, "golfer", use: getGolferHandler)
        scoresRoutes.get(Score.parameter, "scorecard", use: getScorecardHandler)
    }
    
    func createHandler(_ req: Request, score: Score)
        throws -> Future<Score> {
            return score.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Score.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Score> {
        return try flatMap(
            to: Score.self,
            req.parameters.next(Score.self),
            req.content.decode(Score.self)) { score, updatedScore in
                score.date = updatedScore.date
                score.strokesPerHole = updatedScore.strokesPerHole
                score.puttsPerHole = updatedScore.puttsPerHole
                score.greensInRegulation = updatedScore.greensInRegulation
                score.scorecardID = updatedScore.scorecardID
                score.golferID = updatedScore.golferID
                return score.save(on: req)
        }
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Score]> {
        return Score.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Score> {
        return try req.parameters.next(Score.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Score> {
        return Score.query(on: req)
            .first()
            .map(to: Score.self) { score in
                guard let score = score else {
                    throw Abort(.notFound)
                }
                return score
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[Score]> {
        guard let searchTerm =
            req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        return Score.query(on: req).group(.or) { or in
            or.filter(\.totalScoreStr == searchTerm)
            }.all()
    }
    
    func getSortedHandler(_ req: Request) throws -> Future<[Score]> {
        return Score.query(on: req).sort(\.totalScore, .ascending).all()
    }
    
    func getGolferHandler(_ req: Request) throws -> Future<Golfer> {
        return try req.parameters
            .next(Score.self)
            .flatMap(to: Golfer.self) {
                score in score.golfer.get(on: req)
        }
    }
    
    func getScorecardHandler(_ req: Request) throws -> Future<Scorecard> {
        return try req.parameters
            .next(Score.self)
            .flatMap(to: Scorecard.self) {
                score in score.scorecard.get(on:req)
        }
    }

}
