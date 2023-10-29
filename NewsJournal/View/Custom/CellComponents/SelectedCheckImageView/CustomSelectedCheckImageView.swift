//
//  CustomSelectedCheckImageView.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

final class CustomSelectedCheckImageView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        configImageView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configImageView() {
        tintColor = Constant.Color.mainRed
        isHidden = true
    }
    
}
