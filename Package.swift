// swift-tools-version:4.2

import PackageDescription

let package = Package(
	name: "CreateMLDemo",
	products: [
		.executable(name: "PerfectTemplate", targets: ["PerfectTemplate"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "PerfectTemplate", dependencies: ["PerfectHTTPServer"])
	]
)
