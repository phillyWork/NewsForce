//
//  CustomBookMarkButton.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import UIKit

final class CustomBookMarkButton: UIButton {
    
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configButton() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: Constant.Frame.newsBookMarkButtonPointSize, weight: .light)
        setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        setImage(UIImage(systemName: Constant.ImageString.bookMarkImageString), for: .normal)
        tintColor = Constant.Color.mainRed
    }
    
    func setUnselected() {
        setImage(UIImage(systemName: Constant.ImageString.bookMarkImageString), for: .normal)
    }
    
    func setSelected() {
        setImage(UIImage(systemName: Constant.ImageString.selectedBookMarkImageString), for: .normal)
    }
    
}
