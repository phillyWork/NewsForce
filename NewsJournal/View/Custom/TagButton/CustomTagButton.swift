//
//  CustomTagButton.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import UIKit

final class CustomTagButton: UIButton {

    let type: TagType
    
    init(frame: CGRect, type: TagType) {
        self.type = type
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        
        var config = UIButton.Configuration.bordered()
        config.baseBackgroundColor = Constant.Color.whiteBackground
        config.baseForegroundColor = Constant.Color.tagButtonText
        
        var attributedTitle = AttributedString.init(type.rawValue)
        attributedTitle.font = Constant.Font.tagButton
        config.attributedTitle = attributedTitle
        
        self.configuration = config
    }
    
    func changeToSelected() {
        self.configuration?.baseForegroundColor = Constant.Color.mainRed
    }
    
    func changeToUnselected() {
        self.configuration?.baseForegroundColor = Constant.Color.tagButtonText
    }
    
}
