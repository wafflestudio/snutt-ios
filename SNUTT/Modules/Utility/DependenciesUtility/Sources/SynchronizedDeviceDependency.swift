import Dependencies
import DependenciesAdditions
import Foundation
import UIKit.UIDevice

extension DependencyValues {
    public var syncDevice: SynchronizedDevice {
        get { self[SynchronizedDeviceKey.self] }
        set { self[SynchronizedDeviceKey.self] = newValue }
    }
}

enum SynchronizedDeviceKey: DependencyKey {
    public static var liveValue: SynchronizedDevice {
        .current
    }

    public static var testValue: SynchronizedDevice {
        .unimplemented
    }

    static var previewValue: SynchronizedDevice {
        .current
    }
}

public struct SynchronizedDevice: Sendable, ConfigurableProxy {
    public var _implementation: Implementation

    public struct Implementation: Sendable {
        @ReadOnlyProxy public var name: String
        @ReadOnlyProxy public var modelName: String
        @ReadOnlyProxy public var systemName: String
        @ReadOnlyProxy public var systemVersion: String
        @ReadOnlyProxy public var identifierForVendor: String?
    }

    public var name: String {
        _implementation.name
    }

    public var modelName: String {
        _implementation.modelName
    }

    public var systemName: String {
        _implementation.systemName
    }

    public var systemVersion: String {
        _implementation.systemVersion
    }

    public var identifierForVendor: String? {
        _implementation.identifierForVendor
    }

    public nonisolated static var current: SynchronizedDevice {
        .init(
            _implementation: .init(
                name: .init {
                    runOnMain { UIDevice.current.name }
                },
                modelName: .init {
                    runOnMain { deviceModelName() }
                },
                systemName: .init {
                    runOnMain { UIDevice.current.systemName }
                },
                systemVersion: .init {
                    runOnMain { UIDevice.current.systemVersion }
                },
                identifierForVendor: .init {
                    runOnMain { UIDevice.current.identifierForVendor?.uuidString }
                }
            )
        )
    }

    public nonisolated static var unimplemented: SynchronizedDevice {
        .init(
            _implementation: .init(
                name: .unimplemented(#"@Dependency(\.syncDevice.name)"#, placeholder: ""),
                modelName: .unimplemented(#"@Dependency(\.syncDevice.modelName)"#, placeholder: ""),
                systemName: .unimplemented(#"@Dependency(\.syncDevice.systemName)"#, placeholder: ""),
                systemVersion: .unimplemented(#"@Dependency(\.syncDevice.systemVersion)"#, placeholder: ""),
                identifierForVendor: .unimplemented(#"@Dependency(\.syncDevice.identifierForVendor)"#, placeholder: "")
            )
        )
    }
}

extension SynchronizedDevice {
    private static func deviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let data = Data(bytes: &systemInfo.machine, count: MemoryLayout.size(ofValue: systemInfo.machine))
        guard let identifier = String(bytes: data, encoding: .ascii) else {
            return "Unknown"
        }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }

    private static func runOnMain<T>(_ block: @escaping @MainActor () -> T) -> T where T: Sendable {
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                block()
            }
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
}
