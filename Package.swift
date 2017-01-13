import PackageDescription

let package = Package(
   name: "SwiftyFormat",
   dependencies: [
      .Package(url: "https://github.com/Quick/Nimble", majorVersion: 5, minor: 1)
   ]
)
