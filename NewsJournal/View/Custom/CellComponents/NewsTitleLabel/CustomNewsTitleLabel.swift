//
//  CustomNewsTitleLabel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

import SkeletonView

final class CustomNewsTitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configLabel() {
        font = Constant.Font.newsTitleFont
        textAlignment = .natural
        numberOfLines = Constant.Label.newsTitleNumberOfLines
        textColor = Constant.Color.blackText
        isSkeletonable = true
        skeletonCornerRadius = 8
    }
    
}

