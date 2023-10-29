//
//  CustomNewsDateLabel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

import SkeletonView

final class CustomNewsDateLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configLabel() {
        font = Constant.Font.newsDateFont
        textColor = Constant.Color.linkDateShadowText
        isSkeletonable = true
        skeletonCornerRadius = Constant.Frame.skeletonCornerRadius
    }
    
}
