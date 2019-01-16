import Vapor
import Fluent

struct GolfCoursesController: RouteCollection {

    func boot(router: Router) throws {
        let golfCoursesRoutes = router.grouped("api", "golfcourses")
        golfCoursesRoutes.post(GolfCourse.self, use: createHandler)
        golfCoursesRoutes.delete(GolfCourse.parameter, use: deleteHandler)
        golfCoursesRoutes.put(GolfCourse.parameter, use: updateHandler)
        golfCoursesRoutes.get(use: getAllHandler)
        golfCoursesRoutes.get(GolfCourse.parameter, use: getHandler)
        golfCoursesRoutes.get("first", use: getFirstHandler)
        golfCoursesRoutes.get("search", use: getSearchHandler)
        golfCoursesRoutes.get("sorted", use: getSortedHandler)
        golfCoursesRoutes.get(GolfCourse.parameter, "tees", use: getTeesHandler)
    }

    func createHandler(_ req: Request, golfCourse: GolfCourse)
        throws -> Future<GolfCourse> {
        return golfCourse.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(GolfCourse.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try flatMap(
            to: GolfCourse.self,
            req.parameters.next(GolfCourse.self),
            req.content.decode(GolfCourse.self)) { golfCourse, updatedGolfCourse in
                golfCourse.name = updatedGolfCourse.name
                golfCourse.streetAddress = updatedGolfCourse.streetAddress
                golfCourse.city = updatedGolfCourse.city
                golfCourse.state = updatedGolfCourse.state
                golfCourse.phoneNumber = updatedGolfCourse.phoneNumber
                return golfCourse.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        return GolfCourse.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try req.parameters.next(GolfCourse.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<GolfCourse> {
        return GolfCourse.query(on: req)
            .first()
            .map(to: GolfCourse.self) { golfCourse in
                guard let golfCourse = golfCourse else {
                    throw Abort(.notFound)
                }
                return golfCourse
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        return GolfCourse.query(on: req).group(.or) { or in
            or.filter(\.name == searchTerm)
            or.filter(\.streetAddress == searchTerm)
            or.filter(\.city == searchTerm)
            or.filter(\.state == searchTerm)
            or.filter(\.phoneNumber == searchTerm)
        }.all()
    }
    
    func getSortedHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        return GolfCourse.query(on: req).sort(\.name, .ascending).all()
    }
    
    func getTeesHandler(_ req: Request) throws -> Future<[Tee]> {
        return try req.parameters
        .next(GolfCourse.self)
            .flatMap(to: [Tee].self) { golfCourse in
                try golfCourse.tees.query(on: req).all()
        }
    }
}
