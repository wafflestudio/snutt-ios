//
//  FriendsService.swift
//  SNUTT
//
//  Created by user on 2023/08/11.
//

import Alamofire
import Foundation

@MainActor
protocol FriendsServiceProtocol: Sendable {
    @discardableResult func fetchReactNativeBundleUrl() async throws -> URL
}

struct FriendsService: FriendsServiceProtocol, ConfigsProvidable {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    private let rnBundlePath = "ReactNativeBundles"

    private var vacancyRepository: any VacancyRepositoryProtocol {
        webRepositories.vacancyRepository
    }

    private var configRepository: any ConfigRepositoryProtocol {
        webRepositories.configRepository
    }

    private var userDefaultsRepository: any UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    // MARK: RN Bundle Management

    // TODO: refactor with modularization; move to infra layer

    func fetchReactNativeBundleUrl() async throws -> URL {
        let configsDto = try await fetchConfigs()
        guard let remoteUrlString = configsDto.reactNativeBundleFriends?.iosBundleSrc,
              let remoteUrl = URL(string: remoteUrlString)
        else {
            throw STError(.INVALID_RN_BUNDLE)
        }

        let localUrl = constructLocalCacheUrl(from: remoteUrl)
        if FileManager.default.fileExists(atPath: localUrl.path) {
            return localUrl
        }
        clearReactNativeBundlesCache() // always maintain the latest bundle file
        let downloadUrl = try await downloadFile(from: remoteUrl)
        return downloadUrl
    }

    private var bundlesURL: URL {
        guard let cacheURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return FileManager.default.temporaryDirectory
        }
        return cacheURL.appendingPathComponent(rnBundlePath)
    }

    private func constructLocalCacheUrl(from remoteUrl: URL) -> URL {
        var bundlesURL = self.bundlesURL
        for component in remoteUrl.pathComponents.dropFirst() {
            bundlesURL = bundlesURL.appendingPathComponent(component)
        }
        return bundlesURL
    }

    private func clearReactNativeBundlesCache() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: bundlesURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            // pass
        }
    }

    func downloadFile(from remoteUrl: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let destinationBlock: DownloadRequest.Destination = { _, _ in
                let cacheURL = constructLocalCacheUrl(from: remoteUrl)
                return (cacheURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            AF.download(remoteUrl, to: destinationBlock).response { response in
                switch response.result {
                case let .success(url):
                    guard let url else {
                        continuation.resume(throwing: STError(.INVALID_RN_BUNDLE))
                        return
                    }
                    continuation.resume(returning: url)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct FakeFriendsService: FriendsServiceProtocol {
    func fetchReactNativeBundleUrl() async throws -> URL {
        throw STError(.INVALID_RN_BUNDLE)
    }
}
