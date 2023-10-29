//
//  CustomNewsImageView.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

import SkeletonView

final class CustomNewsImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configImageView() {
        contentMode = .scaleAspectFill
        layer.cornerRadius = Constant.Frame.newsImageViewCornerRadius
        clipsToBounds = true
        isSkeletonable = true
        skeletonCornerRadius = Constant.Frame.skeletonCornerRadius
    }
    
}
