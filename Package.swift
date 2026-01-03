// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BlockablePlayer",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "BlockablePlayer", targets: ["BlockablePlayer"])
    ],
    targets: [
        .systemLibrary(
            name: "CLibVLC",
            pkgConfig: "libvlc",
            providers: [.brew(["vlc"])]
        ),
        .executableTarget(
            name: "BlockablePlayer",
            dependencies: ["CLibVLC"],
            path: "Sources/BlockablePlayer",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-L",
                    "-Xlinker", "/Applications/VLC.app/Contents/MacOS/lib"
                ], .when(platforms: [.macOS])),
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "/Applications/VLC.app/Contents/MacOS/lib"
                ], .when(platforms: [.macOS])),
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "@executable_path/../Frameworks"
                ], .when(platforms: [.macOS]))
            ]
        )
    ]
)
