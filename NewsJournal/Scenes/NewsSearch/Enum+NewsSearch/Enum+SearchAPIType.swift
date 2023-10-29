//
//  Enum+SearchAPIType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/21.
//

import Foundation

enum SearchAPIType {
    
    case naver
    case newsAPI
    
    var typeTitle: String {
        switch self {
        case .naver:
            return "국내기사"
        case .newsAPI:
            return "해외기사"
        }
    }

}
