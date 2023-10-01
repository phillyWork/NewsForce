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
    
    
    
}
