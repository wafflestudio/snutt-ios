import Foundation
import os

enum Configuration: String, CaseIterable {
    case dev
    case prod

    var apiSpecRemoteURL: URL {
        switch self {
        case .dev:
            URL(string: "https://snutt-api-dev.wafflestudio.com/v3/api-docs")!
        case .prod:
            URL(string: "https://snutt-api.wafflestudio.com/v3/api-docs")!
        }
    }

    var jsonFileName: String {
        switch self {
        case .dev:
            "openapi-dev.json"
        case .prod:
            "openapi-prod.json"
        }
    }
}

struct OpenAPIDownloader: Sendable {
    private var fileManager: FileManager {
        FileManager.default
    }

    private func openAPISpecPath(for configuration: Configuration) -> URL {
        URL(filePath: fileManager.currentDirectoryPath)
            .appending(path: "OpenAPI")
            .appending(path: configuration.jsonFileName, directoryHint: .notDirectory)
    }

    private func downloadOpenAPISpec(for configuration: Configuration) async throws {
        let fileURL = openAPISpecPath(for: configuration)
        let specURL = configuration.apiSpecRemoteURL
        if fileManager.fileExists(atPath: fileURL.path) {
            print("🔄 OpenAPI spec for \(configuration.rawValue) already exists.")
            return
        }
        try? fileManager.removeItem(at: fileURL)
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        let (rawData, _) = try await URLSession.shared.data(from: specURL)
        let specString = String(data: rawData, encoding: .utf8)?
            .replacingOccurrences(of: "\"400 (1)\"", with: "\"400\"")
            .replacingOccurrences(of: "\"400 (2)\"", with: "\"402\"")
        guard let specString else { throw DownloadError("Failed to process OpenAPI spec") }
        guard let processedData = specString.data(using: .utf8)
        else { throw DownloadError("Failed to convert OpenAPI spec to data") }
        let jsonObject =
            try JSONSerialization.jsonObject(with: processedData, options: []) as! [String: Any]
        let validatedJsonObject = validated(jsonObject: jsonObject)
        let prettyPrintedData = try JSONSerialization.data(
            withJSONObject: validatedJsonObject,
            options: [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        )
        try prettyPrintedData.write(to: fileURL, options: .atomic)
        print("✅ OpenAPI spec for \(configuration.rawValue) downloaded successfully.")
    }

    private func validated(jsonObject: [String: Any]) -> [String: Any] {
        var validatedObject = jsonObject
        validatedObject.updateValueRecursively(
            keyPath: "paths./v1/configs.get.responses.200.content.application/json.schema",
            value: ["type": "object", "additionalProperties": true]
        )
        validatedObject.transformJsonEnumTypesRecursively()
        return validatedObject
    }

    private func downloadAll() async throws {
        let configurations: [Configuration] = [.dev, .prod]
        print("🚀 Starting OpenAPI spec download process...")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for configuration in configurations {
                group.addTask {
                    try await downloadOpenAPISpec(for: configuration)
                }
            }
            try await group.waitForAll()
        }
    }

    func downloadConfiguration(_ configName: String) async throws {
        let configuration: Configuration
        switch configName.lowercased() {
        case "dev":
            configuration = .dev
        case "prod":
            configuration = .prod
        default:
            throw DownloadError("Unknown configuration: \(configName)")
        }

        print("🚀 Downloading OpenAPI spec for \(configuration.rawValue)...")
        try await downloadOpenAPISpec(for: configuration)
    }

    func main() {
        print("")
        let args = CommandLine.arguments
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                if args.count > 1 {
                    let configName = args[1]
                    try await downloadConfiguration(configName)
                } else {
                    print("❌ Configuration is required")
                    print("Usage: swift \(args[0]) [dev|prod]")
                }
            } catch {
                print("❌ Error downloading OpenAPI spec: \(error)")
            }
            semaphore.signal()
        }
        semaphore.wait()
    }

    private struct DownloadError: Error, LocalizedError {
        let message: String
        init(_ message: String) {
            self.message = message
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    mutating func transformJsonEnumTypesRecursively() {
        for key in keys {
            if var nestedDict = self[key] as? [String: Any] {
                nestedDict.transformJsonEnumTypesRecursively()
                self[key] = nestedDict
            }
        }
        if let typeValue = self["type"] as? String, typeValue == "string",
           let enumValue = self["enum"] as? [Any]
        {
            let conversionResult = canConvertAllStringElementsToInt(enumValue)
            if conversionResult.canConvert, let intArray = conversionResult.intArray {
                self["enum"] = intArray
                self["type"] = "integer"
            }
        }
    }

    mutating func updateValueRecursively(keyPath: String, value: Any) {
        let keys = keyPath.split(separator: ".").map(String.init).filter { !$0.isEmpty }
        guard !keys.isEmpty else {
            return
        }
        updateValueRecursiveHelper(at: keys, value: value)
    }

    private mutating func updateValueRecursiveHelper(at keys: [String], value: Any) {
        guard let firstKey = keys.first else {
            return
        }
        let remainingKeys = Array(keys.dropFirst())
        if remainingKeys.isEmpty {
            self[firstKey] = value
        } else {
            var nestedDict: [String: Any]
            if let existingValue = self[firstKey], var dict = existingValue as? [String: Any] {
                nestedDict = dict
            } else {
                nestedDict = [String: Any]()
            }
            nestedDict.updateValueRecursiveHelper(at: remainingKeys, value: value)
            self[firstKey] = nestedDict
        }
    }
}

private func canConvertAllStringElementsToInt(_ array: [Any]) -> (
    canConvert: Bool, intArray: [Int]?
) {
    let intArray = array.compactMap { $0 as? String }.compactMap { Int($0) }
    return (intArray.count == array.count, intArray)
}

OpenAPIDownloader().main()
