//
//  ThemeSettingViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/30.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

class ThemeSettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func updateTheme(_ sender: UIButton) {
        setTheme?()
    }
    
    var setTemporaryTheme: ((_ theme: STTheme) -> ())?
    var setTheme: (() -> ())?
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return STTheme.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "themeSettingCollectionViewCell", for: indexPath)
        
        if let customCell = cell as? ThemeSettingCollectionViewCell {
            customCell.setLabelText("얍얍얍")
            
            guard let theme = STTheme(rawValue: indexPath.row), let image = UIImage(named: theme.getImageName()) else { return cell }
            
            customCell.setThemeImage(image)
            customCell.setLabelText(theme.getName())
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedTheme = STTheme(rawValue: indexPath.row) {
            setTemporaryTheme?(selectedTheme)
        }
    }
    
    private func addCellXib() {
        let nib = UINib(nibName: "ThemeSettingCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "themeSettingCollectionViewCell")
    }
}
