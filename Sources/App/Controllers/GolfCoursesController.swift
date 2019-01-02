import Vapor
import Fluent

struct GolfCoursesController: RouteCollection {

    func boot(router: Router) throws {
        let golfCoursesRoutes = router.grouped("api", "golfcourses")
        golfCoursesRoutes.get(use: getAllHandler)
        golfCoursesRoutes.get(use: getFirstHandler)
        golfCoursesRoutes.get(use: searchHandler)
        golfCoursesRoutes.get(use: sortedHandler)
        golfCoursesRoutes.post(GolfCourse.self, use: createHandler)
        golfCoursesRoutes.put(use: updateHandler)
        golfCoursesRoutes.delete(use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        return GolfCourse.query(on: req).all()
    }
    
    func createHandler(_ req: Request, golfCourse: GolfCourse)
        throws -> Future<GolfCourse> {
        return golfCourse.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try req.parameters.next(GolfCourse.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try flatMap(
            to: GolfCourse.self,
        req.parameters.next(GolfCourse.self),
        req.content.decode(GolfCourse.self)) { golfCourse, updatedGolfCourse in
            golfCourse.name = updatedGolfCourse.name
            golfCourse.address = updatedGolfCourse.address
            return golfCourse.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(GolfCourse.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        return GolfCourse.query(on: req).group(.or) { or in
            or.filter(\.name == searchTerm)
            or.filter(\.address == searchTerm)
        }.all()
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
    
    func sortedHandler(_ req: Request) throws -> Future<[GolfCourse]> {
        return GolfCourse.query(on: req).sort(\.name, ._ascending).all()
    }
}
