//
//  Enum+SubDataType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/03.
//

import Foundation

enum NewsSubDataType {
    
    case link
    case pubDate
    
    var text: String {
        switch self {
        case .link:
            return "링크: "
        case .pubDate:
            return "발행 날짜: "
        }
    }
}

enum JournalSubDataType {
    
    case createdAt
    case editedAt
    
    var text: String {
        switch self {
        case .createdAt:
            return "최초 작성: "
        case .editedAt:
            return "최근 수정: "
        }
    }
}
