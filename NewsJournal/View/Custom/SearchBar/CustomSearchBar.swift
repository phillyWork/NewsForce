//
//  CustomSearchBar.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import UIKit

final class CustomSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSearchBar() {
        tintColor = Constant.Color.mainRed
                
        //취소 버튼 설정
        let cancelButton = self.value(forKey: SearchBarCancelButton.cancelButtonKey) as? UIButton
        cancelButton?.setTitle(SearchBarCancelButton.cancelButtonTitle, for: .highlighted)
        cancelButton?.setTitleColor(Constant.Color.tagButtonText, for: .disabled)
        cancelButton?.setTitleColor(Constant.Color.mainRed, for: .normal)
        
        //내부 textField 설정
        self.searchTextField.backgroundColor = Constant.Color.tagButtonText
        self.searchTextField.textColor = Constant.Color.searchBarText
        self.searchTextField.leftView?.tintColor = Constant.Color.mainRed
    }
    
}
