import Foundation
import os

enum Configuration: String, CaseIterable {
    case dev
    case prod

    var specs: [OpenAPISpec] {
        [mainSpec, evSpec]
    }

    private var mainSpec: OpenAPISpec {
        let remoteURL: URL = {
            switch self {
            case .dev:
                URL(string: "https://snutt-api-dev.wafflestudio.com/v3/api-docs")!
            case .prod:
                URL(string: "https://snutt-api.wafflestudio.com/v3/api-docs")!
            }
        }()
        let jsonFileName: String = {
            switch self {
            case .dev:
                "openapi-dev.json"
            case .prod:
                "openapi-prod.json"
            }
        }()
        return OpenAPISpec(kind: .main, remoteURL: remoteURL, jsonFileName: jsonFileName)
    }

    private var evSpec: OpenAPISpec {
        let remoteURL = URL(string: "https://snutt-ev-api-dev.wafflestudio.com/v3/api-docs")!
        let jsonFileName: String = {
            switch self {
            case .dev:
                "openapi-ev-dev.json"
            case .prod:
                "openapi-ev-prod.json"
            }
        }()
        return OpenAPISpec(kind: .ev, remoteURL: remoteURL, jsonFileName: jsonFileName)
    }
}

enum OpenAPISpecKind: String {
    case main
    case ev
}

struct OpenAPISpec: Sendable {
    let kind: OpenAPISpecKind
    let remoteURL: URL
    let jsonFileName: String
}

struct OpenAPIDownloader: Sendable {
    private var fileManager: FileManager {
        FileManager.default
    }

    private func openAPISpecPath(for spec: OpenAPISpec) -> URL {
        URL(filePath: fileManager.currentDirectoryPath)
            .appending(path: "OpenAPI")
            .appending(path: spec.jsonFileName, directoryHint: .notDirectory)
    }

    private func downloadOpenAPISpec(for configuration: Configuration, spec: OpenAPISpec) async throws {
        let fileURL = openAPISpecPath(for: spec)
        let specURL = spec.remoteURL
        let rawData: Data
        if fileManager.fileExists(atPath: fileURL.path) {
            print(
                "🔄 OpenAPI spec [\(spec.kind.rawValue)] for \(configuration.rawValue) already exists. "
                    + "Revalidating..."
            )
            rawData = try Data(contentsOf: fileURL)
        } else {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let (downloadedData, _) = try await URLSession.shared.data(from: specURL)
            rawData = downloadedData
        }
        let specString = String(data: rawData, encoding: .utf8)?
            .replacingOccurrences(of: "\"400 (1)\"", with: "\"400\"")
            .replacingOccurrences(of: "\"400 (2)\"", with: "\"402\"")
        guard let specString else { throw DownloadError("Failed to process OpenAPI spec") }
        guard let processedData = specString.data(using: .utf8)
        else { throw DownloadError("Failed to convert OpenAPI spec to data") }
        let jsonObject =
            try JSONSerialization.jsonObject(with: processedData, options: []) as! [String: Any]
        let validatedJsonObject = validated(jsonObject: jsonObject, specKind: spec.kind)
        let prettyPrintedData = try JSONSerialization.data(
            withJSONObject: validatedJsonObject,
            options: [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        )
        try prettyPrintedData.write(to: fileURL, options: .atomic)
        print("✅ OpenAPI spec [\(spec.kind.rawValue)] for \(configuration.rawValue) downloaded successfully.")
    }

    private func validated(jsonObject: [String: Any], specKind: OpenAPISpecKind) -> [String: Any] {
        var validatedObject = jsonObject
        switch specKind {
        case .main:
            validatedObject.updateValueRecursively(
                keyPath: "paths./v1/configs.get.responses.200.content.application/json.schema",
                value: ["type": "object", "additionalProperties": true]
            )
        case .ev:
            validatedObject.fixEvLectureSummaryParameterSchemaIfNeeded()
        }
        validatedObject.transformJsonEnumTypesRecursively()
        return validatedObject
    }

    private func downloadAll() async throws {
        let configurations: [Configuration] = [.dev, .prod]
        print("🚀 Starting OpenAPI spec download process...")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for configuration in configurations {
                for spec in configuration.specs {
                    group.addTask {
                        try await downloadOpenAPISpec(for: configuration, spec: spec)
                    }
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

        print("🚀 Downloading OpenAPI specs for \(configuration.rawValue)...")
        for spec in configuration.specs {
            try await downloadOpenAPISpec(for: configuration, spec: spec)
        }
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
    mutating func fixEvLectureSummaryParameterSchemaIfNeeded() {
        guard var paths = self["paths"] as? [String: Any],
            var lectureSummary = paths["/v1/lectures/snutt-summary"] as? [String: Any],
            var get = lectureSummary["get"] as? [String: Any],
            var parameters = get["parameters"] as? [[String: Any]]
        else {
            return
        }

        for index in parameters.indices {
            guard let name = parameters[index]["name"] as? String, name == "snuttId" else {
                continue
            }
            let hasSchema = parameters[index]["schema"] != nil
            let hasContent = parameters[index]["content"] != nil
            if !hasSchema && !hasContent {
                parameters[index]["schema"] = ["type": "string"]
            }
        }

        get["parameters"] = parameters
        lectureSummary["get"] = get
        paths["/v1/lectures/snutt-summary"] = lectureSummary
        self["paths"] = paths
    }

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
            if let existingValue = self[firstKey], let dict = existingValue as? [String: Any] {
                nestedDict = dict
            } else {
                nestedDict = [String: Any]()
            }
            nestedDict.updateValueRecursiveHelper(at: remainingKeys, value: value)
            self[firstKey] = nestedDict
        }
    }
}

private func canConvertAllStringElementsToInt(
    _ array: [Any]
) -> (
    canConvert: Bool, intArray: [Int]?
) {
    let intArray = array.compactMap { $0 as? String }.compactMap { Int($0) }
    return (intArray.count == array.count, intArray)
}

OpenAPIDownloader().main()
