//
//  Enum+ViewControllerType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

enum ViewControllerType {
    
    case newsSearchVC
    case journalVC
    
    var tabbarTitle: String {
        switch self {
        case .newsSearchVC:
            return "기사 목록"
        case .journalVC:
            return "저널 목록"
        }
    }
    
    var tabbarItemString: String {
        switch self {
        case .newsSearchVC:
            return "magnifyingglass"
        case .journalVC:
            return "list.bullet"
        }
    }
    
    var searchBarPlaceholder: String {
        switch self {
        case .newsSearchVC:
            return "기사를 검색해보세요"
        case .journalVC:
            return "검색어를 입력하세요"
        }
    }
    
}
