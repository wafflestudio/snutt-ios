//
//  SystemTabView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit
import UIKitUtility

public class SystemUITabBarController<T: TabItem>: UITabBarController, UITabBarControllerDelegate {
    private let tabItems: [T]
    @Binding private var selectedTabItem: T

    init(
        selectedTabItem: Binding<T>,
        tabScenes: [TabScene<T>]
    ) {
        _selectedTabItem = selectedTabItem
        tabItems = tabScenes.compactMap { $0.tabItem }
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 26, *) {
            configureTabs(tabScenes: tabScenes)
        } else {
            configureViewControllers(tabScenes: tabScenes)
        }
        select(selectedTabItem.wrappedValue)
    }

    /// Builds the tabs with `UITab`, so the search tab is a `UISearchTab` that the tab bar can set apart.
    @available(iOS 26, *)
    private func configureTabs(tabScenes: [TabScene<T>]) {
        let isPad = traitCollection.userInterfaceIdiom == .pad
        tabs = tabScenes.map { scene in
            let viewController = makeViewController(for: scene)
            let tabItem = scene.tabItem
            let tab: UITab =
                tabItem.isSearchRole
                ? UISearchTab { _ in viewController }
                : UITab(title: isPad ? tabItem.title : "", image: nil, identifier: "\(tabItem.viewIndex())") { _ in
                    viewController
                }
            tab.image = tabItem.image(isSelected: false)
            if #available(iOS 26.1, *) {
                tab.selectedImage = tabItem.image(isSelected: true)
            }
            return tab
        }
        #if compiler(>=6.4)
        // Since iOS 27 the search tab is set apart only when it is prominent. It becomes prominent on its own only
        // with `automaticallyActivatesSearch`, which would raise the keyboard every time the tab is selected.
        if #available(iOS 27, *) {
            prominentTabIdentifier = tabs.first { $0 is UISearchTab }?.identifier
        }
        #endif
    }

    private func configureViewControllers(tabScenes: [TabScene<T>]) {
        viewControllers = tabScenes.map { scene in
            let hostingController = makeViewController(for: scene)
            let tabItem = scene.tabItem
            let isPad = traitCollection.userInterfaceIdiom == .pad
            let uiTabItem: UITabBarItem
            if isPad, tabItem.isSearchRole {
                uiTabItem = UITabBarItem(tabBarSystemItem: .search, tag: tabItem.viewIndex())
            } else {
                // A system search item's title can't be cleared on iOS < 26, so use a
                // plain item there instead to actually hide the label.
                uiTabItem = UITabBarItem()
            }
            if isPad {
                uiTabItem.title = tabItem.title
            } else {
                uiTabItem.title = nil
            }
            uiTabItem.image = tabItem.image(isSelected: false)
            uiTabItem.selectedImage = tabItem.image(isSelected: true)
            hostingController.tabBarItem = uiTabItem
            return hostingController
        }
    }

    private func makeViewController(for scene: TabScene<T>) -> UIViewController {
        guard let rootView = scene.rootView else {
            return UIViewController()
        }
        return UIHostingController(rootView: rootView)
    }

    func select(_ tabItem: T) {
        guard let index = tabItems.firstIndex(of: tabItem) else { return }
        if #available(iOS 26, *) {
            guard selectedTab !== tabs[index] else { return }
            selectedTab = tabs[index]
        } else if selectedIndex != index {
            selectedIndex = index
        }
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        if #unavailable(iOS 26) {
            preventTabBarTransparency()
        }
    }

    private func preventTabBarTransparency() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    @available(iOS 26, *)
    private func disableReturnKeyAutomatically() {
        guard let textField = view.findDescendant(ofType: UISearchTextField.self) else { return }
        textField.enablesReturnKeyAutomatically = false
    }

    public func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        guard let viewControllers = tabBarController.viewControllers,
            let index = viewControllers.firstIndex(of: viewController)
        else { return }
        didSelectTab(at: index)
    }

    @available(iOS 18, *)
    public func tabBarController(
        _ tabBarController: UITabBarController,
        didSelectTab selectedTab: UITab,
        previousTab _: UITab?
    ) {
        guard let index = tabBarController.tabs.firstIndex(of: selectedTab) else { return }
        didSelectTab(at: index)
    }

    private func didSelectTab(at index: Int) {
        guard index < tabItems.count else { return }
        selectedTabItem = tabItems[index]

        if #available(iOS 26, *), selectedTabItem.isSearchRole {
            Task {
                disableReturnKeyAutomatically()
            }
        }
    }
}

public struct SystemTabView<T: TabItem>: UIViewControllerRepresentable {
    @Binding var selectedTab: T
    let tabScenes: () -> [TabScene<T>]

    public init(selectedTab: Binding<T>, @TabSceneBuilder tabScenes: @escaping () -> [TabScene<T>]) {
        _selectedTab = selectedTab
        self.tabScenes = tabScenes
    }

    public func makeUIViewController(context _: Context) -> SystemUITabBarController<T> {
        return SystemUITabBarController(selectedTabItem: $selectedTab, tabScenes: tabScenes())
    }

    public func updateUIViewController(_ uiViewController: SystemUITabBarController<T>, context _: Context) {
        uiViewController.select(selectedTab)
    }
}
