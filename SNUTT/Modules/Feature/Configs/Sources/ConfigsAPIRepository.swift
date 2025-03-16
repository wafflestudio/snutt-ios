import Foundation
import APIClientInterface
import ConfigsInterface
import Dependencies

public struct ConfigsAPIRepository: ConfigsRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchConfigs() async throws -> ConfigsModel {
        let configsDict = try await apiClient.getConfigs_1(.init()).ok.body.json.additionalProperties.value
        let jsonData = try JSONSerialization.data(withJSONObject: configsDict)
        return try JSONDecoder().decode(ConfigsModel.self, from: jsonData)
    }
}

