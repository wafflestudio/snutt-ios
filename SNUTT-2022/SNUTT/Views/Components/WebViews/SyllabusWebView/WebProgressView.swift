//
//  WebProgressView.swift
//  SNUTT
//
//  Created by 박신홍 on 10/19/24.
//

import UIKit

final class WebProgressView: UIView {
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
        fatalError()
    }

    private func setupView() {
        progressBar.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        progressBar.layer.shadowColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        progressBar.layer.masksToBounds = false
        addSubview(progressBar)
        setProgress(0)
    }

    func setProgress(_ value: Double) {
        let newProgress = min(max(value, 0.0), 1.0)
        if newProgress < progress {
            progress = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState]) {
            self.progress = newProgress
        }
        if progress == 1 {
            UIView.animate(withDuration: 0.3, delay: 0.5) {
                self.progressBar.alpha = 0
            }
        } else {
            progressBar.alpha = 1
        }
    }

    private func updateProgressBarFrame() {
        let progressBarWidth = CGFloat(progress) * bounds.width
        progressBar.frame = CGRect(x: 0, y: 0, width: progressBarWidth, height: bounds.height)
    }

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 2)
    }
}
