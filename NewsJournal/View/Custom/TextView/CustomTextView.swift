//
//  CustomTextView.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import UIKit

final class CustomTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTextView() {
        font = Constant.Font.memoTextView
        tintColor = Constant.Color.mainRed
        layer.borderColor = Constant.Color.grayForNotSelectedBookMarkedCell.cgColor
        layer.borderWidth = 1
        setInitialPlaceholder()
    }
    
    func showMemo() {
        textColor = Constant.Color.blackText
    }
    
    func removePlaceholder() {
        textColor = Constant.Color.blackText
        text = nil
    }
    
    func setInitialPlaceholder() {
        textColor = Constant.Color.linkDateShadowText
        text = MemoSetupValues.textViewPlaceholders.randomElement()
    }
    
}
