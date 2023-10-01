//
//  CustomBarButtonItem.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import UIKit

final class CustomBarButtonItem: UIBarButtonItem {
    
    let type: BarButtonType
    
    init(type: BarButtonType) {
        self.type = type
        super.init()
        configureBarButtonItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBarButtonItem() {
        style = .plain
        title = type.buttonTitle
        tintColor = Constant.Color.mainRed
    }
    
}
