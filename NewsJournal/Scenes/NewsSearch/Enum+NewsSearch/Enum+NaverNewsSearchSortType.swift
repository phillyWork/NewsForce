//
//  Enum+SortType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

enum NaverNewsSearchSortType: String {
    
    case sim
    case date
        
    var sortTitle: String {
        switch self {
        case .sim:
            return "정확도"
        case .date:
            return "날짜순"
        }
    }
    
}
