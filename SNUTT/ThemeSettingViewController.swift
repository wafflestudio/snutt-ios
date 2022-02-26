//
//  ThemeSettingViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/30.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class ThemeSettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!

    @IBAction func updateTheme(_: UIButton) {
        setTheme?()
    }

    var setTemporaryTheme: ((_ theme: STTheme) -> Void)?
    var setTheme: (() -> Void)?

    var currentTheme: STTheme? {
        return STTimetableManager.sharedInstance.currentTimetable?.theme
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: collectionView.frame.height)

        layout.scrollDirection = .horizontal
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout

        addCellXib()
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return STTheme.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "themeSettingCollectionViewCell", for: indexPath)

        if let customCell = cell as? ThemeSettingCollectionViewCell {
            guard let theme = STTheme(rawValue: indexPath.row), let image = UIImage(named: theme.getImageName()), let currentTheme = currentTheme else { return cell }

            customCell.setThemeImage(image)
            customCell.setLabelText(theme.getName())

            if currentTheme == theme {
                customCell.setThemeSelected()
            } else {
                customCell.setThemeDeselected()
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedTheme = STTheme(rawValue: indexPath.row) {
            setTemporaryTheme?(selectedTheme)
            collectionView.reloadData()
        }
    }

    private func addCellXib() {
        let nib = UINib(nibName: "ThemeSettingCollectionViewCell", bundle: nil)

        collectionView.register(nib, forCellWithReuseIdentifier: "themeSettingCollectionViewCell")
    }
}
