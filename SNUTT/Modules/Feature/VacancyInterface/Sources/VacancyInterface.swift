import SwiftUI

@MainActor
public protocol VacancyUIProvidable {
    associatedtype VacancyScene: View
    func makeVacancyScene() -> VacancyScene
}

private struct EmptyVacancyUIProvider: VacancyUIProvidable {
    func makeVacancyScene() -> Text {
        Text("VacancyUIProvider not found.")
    }
}

extension EnvironmentValues {
    @Entry public var vacancyUIProvider: any VacancyUIProvidable = EmptyVacancyUIProvider()
}
