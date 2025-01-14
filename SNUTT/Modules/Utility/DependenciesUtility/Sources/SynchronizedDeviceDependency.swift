@_spi(Internals) import DependenciesAdditionsBasics
import UIKit.UIDevice

public extension DependencyValues {
    var syncDevice: SynchronizedDevice {
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
    @_spi(Internals) public var _implementation: Implementation

    public struct Implementation: Sendable {
        @ReadOnlyProxy public var name: String
        @ReadOnlyProxy public var systemName: String
        @ReadOnlyProxy public var systemVersion: String
        @ReadOnlyProxy public var identifierForVendor: String?
    }

    public var name: String {
        _implementation.name
    }

    public var systemName: String {
        _implementation.systemName
    }

    public var systemVersion: String {
        _implementation.systemVersion
    }

    public var identifierForVendor: String? {
        _implementation.systemVersion
    }

    public nonisolated static var current: SynchronizedDevice {
        .init(_implementation: .init(
            name: .init {
                runOnMain { UIDevice.current.name }
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
        ))
    }

    public nonisolated static var unimplemented: SynchronizedDevice {
        .init(_implementation: .init(
            name: .unimplemented(#"@Dependency(\.syncDevice.name)"#, placeholder: ""),
            systemName: .unimplemented(#"@Dependency(\.syncDevice.systemName)"#, placeholder: ""),
            systemVersion: .unimplemented(#"@Dependency(\.syncDevice.systemVersion)"#, placeholder: ""),
            identifierForVendor: .unimplemented(#"@Dependency(\.syncDevice.identifierForVendor)"#, placeholder: "")
        ))
    }
}

extension SynchronizedDevice {
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
