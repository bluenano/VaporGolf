import Vapor
import Fluent
import Authentication

struct ScoresController: RouteCollection {
    
    func boot(router: Router) throws {
        let scoresRoutes = router.grouped("api", "scores")
        scoresRoutes.get(use: getAllHandler)
        scoresRoutes.get(Score.parameter, use: getHandler)
        scoresRoutes.get("first", use: getFirstHandler)
        scoresRoutes.get("search", use: getSearchHandler)
        scoresRoutes.get("sorted", use: getSortedHandler)
        scoresRoutes.get(Score.parameter, "golfer", use: getGolferHandler)
        scoresRoutes.get(Score.parameter, "tee", use: getTeeHandler)
        
        let tokenAuthMiddleware = Golfer.tokenAuthMiddleware()
        let guardAuthMiddleware = Golfer.guardAuthMiddleware()
        let tokenAuthGroup = scoresRoutes.grouped(tokenAuthMiddleware,
                                                  guardAuthMiddleware)
        tokenAuthGroup.post(ScoreCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Score.parameter, use: deleteHandler)
        tokenAuthGroup.put(Score.parameter, use: updateHandler)
    }
    
    func createHandler(_ req: Request, data: ScoreCreateData) throws -> Future<Score> {
        let golfer = try req.requireAuthenticated(Golfer.self)
        let score = try Score(date: data.date,
                              strokesPerHole: data.strokesPerHole,
                              puttsPerHole: data.puttsPerHole,
                              greensInRegulation: data.greensInRegulation,
                              fairwaysHit: data.fairwaysHit,
                              golferID: golfer.requireID(),
                              teeID: data.teeID)
        return score.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        _ = try req.requireAuthenticated(Golfer.self)
        return try req.parameters
            .next(Score.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Score> {
        return try flatMap(
            to: Score.self,
            req.parameters.next(Score.self),
            req.content.decode(ScoreCreateData.self)) { score, updatedScore in
                score.date = updatedScore.date
                score.strokesPerHole = updatedScore.strokesPerHole
                score.puttsPerHole = updatedScore.puttsPerHole
                score.greensInRegulation = updatedScore.greensInRegulation
                score.fairwaysHit = updatedScore.fairwaysHit
                score.teeID = updatedScore.teeID
                let golfer = try req.requireAuthenticated(Golfer.self)
                score.golferID = try golfer.requireID()
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
    
    func getGolferHandler(_ req: Request) throws -> Future<Golfer.Public> {
        return try req.parameters
            .next(Score.self)
            .flatMap(to: Golfer.Public.self) {
                score in score.golfer.get(on: req).convertToPublic()
        }
    }

    func getTeeHandler(_ req: Request) throws -> Future<Tee> {
        return try req.parameters
            .next(Score.self)
            .flatMap(to: Tee.self) {
                score in score.tee.get(on: req)
        }
    }
    
    func getScoreImageHandler(_ req: Request) throws -> Future<[ScoreImage]> {
        return try req.parameters
            .next(Score.self)
            .flatMap(to: [ScoreImage].self) { score in
                try score.scoreImage.query(on: req).all()
        }
    }
}

struct ScoreCreateData: Content {
    let date: Date
    let strokesPerHole: [Int]
    let puttsPerHole: [Int]
    let greensInRegulation: [Bool]
    let fairwaysHit: [Bool]
    let teeID: Tee.ID
}
