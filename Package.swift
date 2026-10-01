// swift-tools-version: 6.0
// @ai-generated(solo)

import PackageDescription

let package = Package(
	name: "swift-gpu-ui",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
	],
	products: [
		.library(name: "GPUUI", targets: ["GPUUI"]),
	],
	targets: [
		// C header with structs shared by Swift and MSL, so both sides agree on memory layout.
		.target(name: "ShaderTypes"),
		.target(
			name: "GPUUI",
			dependencies: ["ShaderTypes"]
		),
		.testTarget(
			name: "GPUUITests",
			dependencies: ["GPUUI"]
		),
	]
)
