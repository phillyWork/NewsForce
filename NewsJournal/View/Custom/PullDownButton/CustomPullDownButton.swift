//
//  CustomPullDownButton.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import UIKit

final class CustomPullDownButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        backgroundColor = Constant.Color.mainRed
        showsMenuAsPrimaryAction = true
        changesSelectionAsPrimaryAction = true
        layer.cornerRadius = Constant.Frame.memoTagButtonCornerRadius
        clipsToBounds = true
    }
    
}
