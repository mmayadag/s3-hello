// swift-tools-version:5.1

import PackageDescription


let package = Package(
    name: "hello",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git",from:"2.9.1"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from:"1.9.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git",from:"3.2.0")
    ],
    targets:[
        .target(
            name:"hello",
            dependencies:["Kitura","HeliumLogger","PerfectCrypto"]
        )
    ]
)
