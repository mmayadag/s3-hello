import Kitura

import LoggerAPI
import HeliumLogger

import PerfectCrypto
import Foundation

// MARK: NEVER DO THIS IN PRODUCTION! PRIVATE KEYS SHOULD BE KEPT SECURE!
let publicKey = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQAB\n-----END PUBLIC KEY-----\n"

// Setup logger
Log.logger = HeliumLogger(.info)

// Setup JWT middleware
class JWTMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        func sendAuthFailed() {
            do {
                response.send("authorization failed\n")
                try response.status(.unauthorized).end()
            } catch {
                Log.error("failed to set unauthorized status: \(error)")
            }
        }

        if let authHeader = request.headers["Authorization"] {
            let signedJWTToken = authHeader.components(separatedBy: " ")[1]
            do {
                guard let jwt = JWTVerifier(signedJWTToken) else {
                    Log.error("failed to verify \(signedJWTToken)")
                    sendAuthFailed()
                    return
                }
                let publicKeyAsPem = try PEMKey(source: publicKey)
            	try jwt.verify(algo: .rs256, key: publicKeyAsPem)
                guard let issuer = jwt.payload["issuer"] as? String,
                    let issuedAtInterval = jwt.payload["issuedAt"] as? Double,
                    let expirationInterval = jwt.payload["expiration"] as? Double else {
                    Log.error("couldn't find issuer, issuedAt, and expiration in \(jwt.payload)")
                    sendAuthFailed()
                    return
                }
                Log.info("*token verified*")
                Log.info("issuer: \(issuer)")
                Log.info("issuedAt: \(Date(timeIntervalSince1970: issuedAtInterval))")
                Log.info("expiration: \(Date(timeIntervalSince1970: expirationInterval))")
                next()
                return
            } catch {
                Log.error("failed to decode or validate \(signedJWTToken): \(error)")
            }
        } else {
            Log.error("no authorization header")
        }
    }
}
let jwtMiddleware = JWTMiddleware()

// Create logging middleware
class RequestLogger: RouterMiddleware {
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.info("\(request.method) request made for \(request.originalURL)")
        next()
    }
}

// Create a new router
let router = Router()

// Setup secure routes
router.all("/*", middleware: RequestLogger())
router.all("/secure", middleware: jwtMiddleware)

// Route requests
router.get("/") { request, response, next in
    response.send(json: ["message": "Hello from Swift!"])
    next()
}
router.get("/secure") { request, response, next in
    response.send(json: ["message": "Secure hello from Swift!"])
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8081, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
