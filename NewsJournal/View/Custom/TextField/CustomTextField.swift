//
//  CustomTextField.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import UIKit

final class CustomTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTextField() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        leftViewMode = .always
        placeholder = MemoSetupValues.textFieldPlaceholder
        tintColor = Constant.Color.mainRed
        backgroundColor = Constant.Color.tagButtonText
        layer.cornerRadius = Constant.Frame.memoTitleTextFieldCornerRadius
    }
    
}

