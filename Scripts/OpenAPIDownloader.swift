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
            validatedObject.replaceWildcardJsonContentTypesRecursively()
            validatedObject.convertSchemaPropertyNamesToSnakeCase()
            validatedObject.addEvaluationCountToLectureSummariesIfNeeded()
            validatedObject.flattenEvLectureSearchParametersIfNeeded()
            validatedObject.relaxEvClassificationEnums()
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

    /// The EV server serializes JSON with Jackson's snake_case naming strategy, which springdoc does not reflect.
    mutating func convertSchemaPropertyNamesToSnakeCase() {
        guard var components = self["components"] as? [String: Any],
            var schemas = components["schemas"] as? [String: Any]
        else {
            return
        }
        for (name, value) in schemas {
            guard var schema = value as? [String: Any] else { continue }
            if let properties = schema["properties"] as? [String: Any] {
                schema["properties"] = Dictionary(
                    uniqueKeysWithValues: properties.map { ($0.key.snakeCased, $0.value) }
                )
            }
            if let required = schema["required"] as? [String] {
                schema["required"] = required.map(\.snakeCased)
            }
            schemas[name] = schema
        }
        components["schemas"] = schemas
        self["components"] = components
    }

    /// The EV server returns `evaluation_count` in lecture summaries, but the spec omits it.
    mutating func addEvaluationCountToLectureSummariesIfNeeded() {
        for schemaName in ["LectureEvaluationSimpleSummary", "LectureEvaluationSummary"] {
            updateValueRecursively(
                keyPath: "components.schemas.\(schemaName).properties.evaluation_count",
                value: ["type": "integer", "format": "int64"]
            )
        }
    }

    /// Lecture classifications are free-form on the server (e.g. an empty string), so a closed enum fails decoding.
    mutating func relaxEvClassificationEnums() {
        guard var components = self["components"] as? [String: Any],
            var schemas = components["schemas"] as? [String: Any]
        else {
            return
        }
        for (name, value) in schemas {
            guard var schema = value as? [String: Any],
                var properties = schema["properties"] as? [String: Any],
                var classification = properties["classification"] as? [String: Any]
            else { continue }
            classification.removeValue(forKey: "enum")
            properties["classification"] = classification
            schema["properties"] = properties
            schemas[name] = schema
        }
        components["schemas"] = schemas
        self["components"] = components
    }

    /// `GET /v1/lectures` binds its query parameters into a `SearchLectureRequest` object, which the generator
    /// cannot encode because the object contains an array. Expose the fields as top-level query parameters instead.
    mutating func flattenEvLectureSearchParametersIfNeeded() {
        guard var paths = self["paths"] as? [String: Any],
            var lectures = paths["/v1/lectures"] as? [String: Any],
            var get = lectures["get"] as? [String: Any],
            let parameters = get["parameters"] as? [[String: Any]],
            parameters.contains(where: { $0["name"] as? String == "params" })
        else {
            return
        }
        get["parameters"] = [
            ["name": "query", "in": "query", "required": true, "schema": ["type": "string"]],
            ["name": "page", "in": "query", "required": true, "schema": ["type": "integer", "format": "int32"]],
            [
                "name": "tags", "in": "query", "required": false, "explode": true, "style": "form",
                "schema": ["type": "array", "items": ["type": "integer", "format": "int64"]],
            ],
        ]
        lectures["get"] = get
        paths["/v1/lectures"] = lectures
        self["paths"] = paths
    }

    mutating func replaceWildcardJsonContentTypesRecursively() {
        for key in keys {
            if var nestedDict = self[key] as? [String: Any] {
                nestedDict.replaceWildcardJsonContentTypesRecursively()
                self[key] = nestedDict
            } else if var nestedArray = self[key] as? [[String: Any]] {
                for index in nestedArray.indices {
                    nestedArray[index].replaceWildcardJsonContentTypesRecursively()
                }
                self[key] = nestedArray
            }
        }
        guard var content = self["content"] as? [String: Any],
            let wildcardContent = content["*/*"] as? [String: Any],
            wildcardContent["schema"] != nil,
            content["application/json"] == nil
        else {
            return
        }
        content["application/json"] = wildcardContent
        content.removeValue(forKey: "*/*")
        self["content"] = content
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

extension String {
    fileprivate var snakeCased: String {
        reduce(into: "") { result, character in
            if character.isUppercase {
                result += "_" + character.lowercased()
            } else {
                result.append(character)
            }
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
