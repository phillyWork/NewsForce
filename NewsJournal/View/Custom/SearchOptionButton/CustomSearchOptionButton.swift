//
//  CustomSearchOptionButton.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/22.
//

import UIKit

final class CustomSearchOptionButton: UIButton {
    
    let title: String
    
    var isButtonSelected: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    init(frame: CGRect, title: String) {
        self.title = title
        super.init(frame: frame)
        configButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configButton() {
        var buttonConfiguration = UIButton.Configuration.borderless()
        var attributedTitle = AttributedString.init(title)
        attributedTitle.font = Constant.Font.searchOptionButton
        buttonConfiguration.attributedTitle = attributedTitle
        buttonConfiguration.baseForegroundColor = Constant.Color.blackText
        buttonConfiguration.image = UIImage(systemName: Constant.ImageString.circleImageString)?.withTintColor(Constant.Color.mainRed, renderingMode: .alwaysOriginal)
        configuration = buttonConfiguration
    }
        
    private func updateUI() {
        if isButtonSelected {
            configuration?.image = UIImage(systemName: Constant.ImageString.selectedCheckCircleMarkImageString)?.withTintColor(Constant.Color.mainRed, renderingMode: .alwaysOriginal)
        } else {
            configuration?.image = UIImage(systemName: Constant.ImageString.circleImageString)?.withTintColor(Constant.Color.mainRed, renderingMode: .alwaysOriginal)
        }
    }
}
