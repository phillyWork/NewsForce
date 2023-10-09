//
//  Font.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import UIKit

extension Constant {
    
    enum Font {
        
        static let toastMessageFont = UIFont.preferredFont(forTextStyle: .footnote)
        
        static let tagButton = UIFont.systemFont(ofSize: 14, weight: .semibold)
        static let journalRealmCellTitle = UIFont.boldSystemFont(ofSize: 13)
        static let journalRealmCellMemo = UIFont.systemFont(ofSize: 11, weight: .medium)
        
        static let pdfCreatorNewsTitle = UIFont.boldSystemFont(ofSize: 15)
        static let pdfCreatorMemoTitle = UIFont.boldSystemFont(ofSize: 25)
        static let pdfCreatorLinkDate = UIFont.systemFont(ofSize: 11, weight: .light)
        static let pdfCreatorTag = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let pdfCreatorContent = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        static let pdfPageInfoLabel = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        static let memoTextView = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    
}
