//
//  SystemTabView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

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

        viewControllers = tabScenes.enumerated().map { index, scene in
            guard let rootView = scene.rootView else {
                return UIViewController()
            }
            let hostingController = UIHostingController(rootView: rootView)
            let tabItem = scene.tabItem
            hostingController.tabBarItem = UITabBarItem(
                title: nil,
                image: tabItem.image(isSelected: false),
                selectedImage: tabItem.image(isSelected: true)
            )
            return hostingController
        }

        selectedIndex = selectedTabItem.wrappedValue.viewIndex()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    public func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        guard let viewControllers = tabBarController.viewControllers,
            let index = viewControllers.firstIndex(of: viewController),
            index < tabItems.count
        else { return }
        selectedTabItem = tabItems[index]
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
        let newIndex = selectedTab.viewIndex()
        if uiViewController.selectedIndex != newIndex {
            uiViewController.selectedIndex = newIndex
        }
    }
}
