//
//  CustomNewsPressLabel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

import SkeletonView

final class CustomNewsPressLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configLabel() {
        font = Constant.Font.newsPressFont
        textColor = Constant.Color.blackText
        textAlignment = .right
        isSkeletonable = true
        skeletonCornerRadius = Constant.Frame.skeletonCornerRadius
    }
    
}
