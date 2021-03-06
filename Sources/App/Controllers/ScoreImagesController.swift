import Vapor
import Fluent

struct ScoreImagesController: RouteCollection {
    
    func boot(router: Router) throws {
        let scoreImagesRoutes = router.grouped("api", "scoreimages")
        scoreImagesRoutes.get(use: getAllHandler)
        scoreImagesRoutes.get(ScoreImage.parameter, use: getHandler)
        scoreImagesRoutes.get(ScoreImage.parameter, "first", use: getFirstHandler)
        scoreImagesRoutes.get(ScoreImage.parameter, "score", use: getScoreHandler)
        
        let tokenAuthMiddleware = Golfer.tokenAuthMiddleware()
        let guardAuthMiddleware = Golfer.guardAuthMiddleware()
        let tokenAuthGroup = scoreImagesRoutes.grouped(tokenAuthMiddleware,
                                                       guardAuthMiddleware)
        tokenAuthGroup.post(ScoreImage.self, use: createHandler)
        tokenAuthGroup.delete(ScoreImage.parameter, use: deleteHandler)
        tokenAuthGroup.put(ScoreImage.parameter, use: updateHandler)
    }
    
    func createHandler(_ req: Request, scoreImage: ScoreImage) throws -> Future<ScoreImage> {
        // here is where to start processing the ScoreImage to extract Score data
        // in the future, remove Score parent foreign key constraint so
        // we do not need a Score to create a ScoreImage
        _ = try req.requireAuthenticated(Golfer.self)
        return scoreImage.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        _ = try req.requireAuthenticated(Golfer.self)
        return try req.parameters
            .next(ScoreImage.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<ScoreImage> {
        _ = try req.requireAuthenticated(Golfer.self)
        return try flatMap(
            to: ScoreImage.self,
            req.parameters.next(ScoreImage.self),
            req.content.decode(ScoreImage.self)) {
                scoreImage, updatedScoreImage in
                scoreImage.imageData = updatedScoreImage.imageData
                scoreImage.scoreID = updatedScoreImage.scoreID
                return scoreImage.save(on: req)
            }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[ScoreImage]> {
        return ScoreImage.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<ScoreImage> {
        return try req.parameters.next(ScoreImage.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<ScoreImage> {
        return ScoreImage.query(on: req)
            .first()
            .map(to: ScoreImage.self) { scoreImage in
                guard let scoreImage = scoreImage else {
                    throw Abort(.notFound)
                }
                return scoreImage
        }
    }
    
    func getScoreHandler(_ req: Request) throws -> Future<Score> {
        return try req.parameters
            .next(ScoreImage.self)
            .flatMap(to: Score.self) {
                scoreImage in scoreImage.score.get(on: req)
        }
    }
}
