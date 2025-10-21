//
//  WebProgressView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import UIKit

final class WebProgressView: UIView {
    private enum Design {
        static let height: CGFloat = 2
        static let animationDuration: TimeInterval = 0.3
        static let fadeDelay: TimeInterval = 0.5
    }

    private let progressBar = UIView()
    private var progress: Double = 0 {
        didSet {
            updateProgressBarFrame()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: Design.height)
    }

    func setProgress(_ value: Double) {
        let newProgress = min(max(value, 0.0), 1.0)
        if newProgress < progress {
            progress = 0
        }

        UIView.animate(withDuration: Design.animationDuration, delay: 0, options: [.beginFromCurrentState]) {
            self.progress = newProgress
        }

        if progress == 1 {
            UIView.animate(withDuration: Design.animationDuration, delay: Design.fadeDelay) {
                self.progressBar.alpha = 0
            }
        } else {
            progressBar.alpha = 1
        }
    }

    private func setupView() {
        progressBar.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        progressBar.layer.shadowColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        progressBar.layer.masksToBounds = false
        addSubview(progressBar)
        setProgress(0)
    }

    private func updateProgressBarFrame() {
        let progressBarWidth = CGFloat(progress) * bounds.width
        progressBar.frame = CGRect(x: 0, y: 0, width: progressBarWidth, height: bounds.height)
    }
}
