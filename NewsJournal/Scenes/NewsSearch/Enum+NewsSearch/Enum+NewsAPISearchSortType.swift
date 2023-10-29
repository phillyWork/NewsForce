//
//  Enum+NewsAPISearchSortType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/23.
//

import Foundation

enum NewsAPISearchSortType: String {
    
    case relevancy
    case popularity
    case publishedAt
        
    var sortTitle: String {
        switch self {
        case .relevancy:
            return "정확도"
        case .popularity:
            return "화제도"
        case .publishedAt:
            return "날짜순"
        }
    }
    
}
