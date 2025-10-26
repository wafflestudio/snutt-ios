//
//  AnimatableTabView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

public class AnimatableUITabBarController<T: TabItem>: UITabBarController, UITabBarControllerDelegate {
    private let tabItems: [T]
    private var isTransitionInProgress = false
    @Binding private var selectedTabItem: T {
        didSet {
            updateAllTabButtonConfigurations()
        }
    }

    private var tabButtons = [T: UIButton]()

    enum Design {
        static var tabBarHeightExcludingSafeArea: CGFloat { 49.0 }
    }

    init(
        selectedTabItem: Binding<T>,
        tabScenes: [TabScene<T>]
    ) {
        _selectedTabItem = selectedTabItem
        tabItems = tabScenes.compactMap { $0.tabItem }
        super.init(nibName: nil, bundle: nil)
        delegate = self
        viewControllers =
            tabScenes
            .compactMap { $0.rootView }
            .map { UIHostingController(rootView: $0) }
    }

    func selectTab(_ tab: T) {
        guard !isTransitionInProgress else { return }
        selectedTabItem = tab
        guard selectedIndex != tab.viewIndex() else { return }
        isTransitionInProgress = true
        selectedIndex = tab.viewIndex()
        view.isUserInteractionEnabled = true
    }

    private lazy var animatableTabBar = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        return view
    }()

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        tabBar.isHidden = true
        let tabBarHeight = Design.tabBarHeightExcludingSafeArea
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        for tabItem in tabItems {
            let button = makeTabButton(for: tabItem)
            let fixedSizeView = CenterContainerView(contentView: button)
            stackView.addArrangedSubview(fixedSizeView)
        }
        view.addSubview(animatableTabBar)
        animatableTabBar.contentView.addSubview(stackView)
        animatableTabBar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(tabBar)
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        stackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(tabBarHeight)
        }
    }

    private func makeTabButton(for tabItem: T) -> UIButton {
        let button = AnimatableUIButton(
            animationOptions: .identity
                .scale(0.8)
                .backgroundColor(touchDown: .black.opacity(0.1))
                .impact()
        )
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .large
        button.configuration = configuration
        button.addAction { [weak self] in
            guard let self else { return }
            selectTab(tabItem)
        }
        button.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration?.image = tabItem.image(isSelected: selectedTabItem == tabItem)
        }
        tabButtons[tabItem] = button
        return button
    }

    public func updateAllTabButtonConfigurations() {
        for button in tabButtons.values {
            button.setNeedsUpdateConfiguration()
        }
    }

    public func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        guard let viewControllers = tabBarController.viewControllers,
            let fromIndex = viewControllers.firstIndex(of: fromVC),
            let toIndex = viewControllers.firstIndex(of: toVC)
        else {
            isTransitionInProgress = false
            return nil
        }
        let direction: SlideTransitionAnimator.Direction = toIndex > fromIndex ? .right : .left
        return SlideTransitionAnimator(
            direction: direction,
            completion: { [weak self] in
                self?.isTransitionInProgress = false
            }
        )
    }
}

private class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case left
        case right
    }

    private let direction: Direction
    private let completion: () -> Void
    init(direction: Direction, completion: @escaping () -> Void) {
        self.direction = direction
        self.completion = completion
    }

    func transitionDuration(using _: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            completion()
            return
        }
        let containerView = transitionContext.containerView
        let directionMultiplier: CGFloat = direction == .right ? 1 : -1
        let offset = directionMultiplier * 10
        containerView.addSubview(toView)
        toView.alpha = 0.3
        toView.transform = .init(translationX: offset, y: 0)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 10
        ) {
            fromView.transform = .init(translationX: -offset / 2, y: 0)
            toView.transform = .identity
            toView.alpha = 1
        } completion: { _ in
            fromView.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.completion()
        }
    }
}

public struct AnimatableTabView<T: TabItem>: UIViewControllerRepresentable {
    @Binding var selectedTab: T
    let tabScenes: () -> [TabScene<T>]

    public init(selectedTab: Binding<T>, @TabSceneBuilder tabScenes: @escaping () -> [TabScene<T>]) {
        _selectedTab = selectedTab
        self.tabScenes = tabScenes
    }

    public func makeUIViewController(context _: Context) -> AnimatableUITabBarController<T> {
        return AnimatableUITabBarController(selectedTabItem: $selectedTab, tabScenes: tabScenes())
    }

    public func updateUIViewController(_: AnimatableUITabBarController<T>, context _: Context) {}
}

@MainActor
@resultBuilder
public enum TabSceneBuilder {
    public static func buildBlock<T>(_ components: TabScene<T>...) -> [TabScene<T>] {
        return components
    }
}

@MainActor
public struct TabScene<T: TabItem> {
    let tabItem: T
    let rootView: AnyView?

    public init<Content>(tabItem: T, rootView: Content) where Content: View {
        self.tabItem = tabItem
        self.rootView = AnyView(rootView)
    }

    public init(tabItem: T) {
        self.tabItem = tabItem
        rootView = nil
    }
}

#Preview {
    struct ColorView: View {
        let color: Color
        init(color: Color) {
            self.color = color
        }

        var body: some View {
            ZStack {
                color
                    .ignoresSafeArea()
                Text(String(describing: color))
            }
        }
    }
    enum PreviewTabItem: Int, TabItem {
        case timetable, search, friends, review, settings
        func image(isSelected _: Bool) -> UIImage {
            UIImage.checkmark
        }

        func viewIndex() -> Int {
            switch self {
            case .timetable, .search: 0
            case .friends: 1
            case .review: 2
            case .settings: 3
            }
        }
    }
    struct PreviewWrapper: View {
        @State var selectedTab = PreviewTabItem.timetable
        var body: some View {
            AnimatableTabView(selectedTab: $selectedTab) {
                TabScene(tabItem: PreviewTabItem.timetable, rootView: ColorView(color: .red))
                TabScene(tabItem: PreviewTabItem.search)
                TabScene(tabItem: PreviewTabItem.friends, rootView: ColorView(color: .yellow))
                TabScene(tabItem: PreviewTabItem.review, rootView: ColorView(color: .green))
                TabScene(tabItem: PreviewTabItem.settings, rootView: ColorView(color: .purple))
            }
            .ignoresSafeArea()
        }
    }
    return PreviewWrapper()
}
