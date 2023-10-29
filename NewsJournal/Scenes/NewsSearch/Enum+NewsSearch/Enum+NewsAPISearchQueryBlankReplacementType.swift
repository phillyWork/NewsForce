//
//  Enum+NewsAPISearchQueryBlankReplacementType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/28.
//

import Foundation

enum NewsAPISearchQueryBlankReplacementType {
    
    case asAnd
    case asOr
    
    var title: String {
        switch self {
        case .asAnd:
            return "검색어 모두 포함"
        case .asOr:
            return "검색어 하나라도 포함"
        }
    }
    
}
