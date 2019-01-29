import Vapor
import Fluent
import Crypto

struct GolfersController: RouteCollection {
    
    func boot(router: Router) throws {
        let golfersRoutes = router.grouped("api", "golfers")
        golfersRoutes.delete(Golfer.parameter, use: deleteHandler)
        golfersRoutes.put(Golfer.parameter, use: updateHandler)
        golfersRoutes.get(use: getAllHandler)
        golfersRoutes.get(Golfer.parameter, use: getHandler)
        golfersRoutes.get("first", use: getFirstHandler)
        golfersRoutes.get("search", use: getSearchHandler)
        golfersRoutes.get("sorted", use: getSortedHandler)
        golfersRoutes.get(Golfer.parameter, "scores", use: getScoresHandler)
        
        let basicAuthMiddleware = Golfer.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = golfersRoutes.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = Golfer.tokenAuthMiddleware()
        let guardAuthMiddleware = Golfer.guardAuthMiddleware()
        let tokenAuthGroup = golfersRoutes.grouped(tokenAuthMiddleware,
                                                   guardAuthMiddleware)
        tokenAuthGroup.post(Golfer.self, use: createHandler)
    }
    
    func createHandler(_ req: Request, golfer: Golfer) throws -> Future<Golfer.Public> {
            golfer.password = try BCrypt.hash(golfer.password)
            return golfer.save(on: req).convertToPublic()
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Golfer.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
        
    }
    
    func updateHandler(_ req: Request) throws -> Future<Golfer.Public> {
        return try flatMap(
            to: Golfer.Public.self,
            req.parameters.next(Golfer.self),
            req.content.decode(Golfer.self)) {
                golfer, updatedGolfer in
                golfer.username = updatedGolfer.username
                golfer.password = try BCrypt.hash(updatedGolfer.password)
                golfer.firstname = updatedGolfer.firstname
                golfer.lastname = updatedGolfer.lastname
                golfer.age = updatedGolfer.age
                golfer.height = updatedGolfer.height
                golfer.weight = updatedGolfer.weight
                golfer.gender = updatedGolfer.gender
                return golfer.save(on: req).convertToPublic()
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Golfer.Public]> {
        return Golfer.query(on: req).decode(data: Golfer.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Golfer.Public> {
        return try req.parameters.next(Golfer.self).convertToPublic()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Golfer.Public> {
        return Golfer.query(on: req)
            .first()
            .map(to: Golfer.Public.self) { golfer in
                guard let golfer = golfer else {
                    throw Abort(.notFound)
                }
                return golfer.convertToPublic()
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[Golfer.Public]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Golfer.query(on: req)
            .decode(data: Golfer.Public.self)
            .group(.or) { or in
            or.filter(\.username == searchTerm)
            or.filter(\.firstname == searchTerm)
            or.filter(\.lastname == searchTerm)
            //or.filter(\.ageStr == searchTerm) ambiguous type without more context issue
            //or.filter(\.heightStr == searchTerm)
            //or.filter(\.weightStr == searchTerm)
            or.filter(\.gender == searchTerm)
        }.all()
    }

    func getSortedHandler(_ req: Request) throws -> Future<[Golfer.Public]> {
        return Golfer.query(on: req)
            .decode(data: Golfer.Public.self)
            .sort(\.lastname, .ascending)
            .all()
    }
    
    func getScoresHandler(_ req: Request) throws -> Future<[Score]> {
        return try req.parameters
            .next(Golfer.self)
            .flatMap(to: [Score].self) { golfer in
                try golfer.scores.query(on: req).all()
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let golfer = try req.requireAuthenticated(Golfer.self)
        let token = try Token.generate(for: golfer)
        return token.save(on: req)
    }
 }
