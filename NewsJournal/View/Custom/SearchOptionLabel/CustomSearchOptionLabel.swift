//
//  CustomSearchOptionLabel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/28.
//

import UIKit

final class CustomSearchOptionLabel: UILabel {
    
    let type: SearchOptionTitle
    
    init(frame: CGRect, type: SearchOptionTitle) {
        self.type = type
        super.init(frame: frame)
        configLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configLabel() {
        text = type.rawValue
        font = Constant.Font.optionTitleLabel
        
    }
    
}
