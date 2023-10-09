//
//  Enum+WebViewError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/04.
//

import Foundation

enum WebViewError: Error {
    
    case invalidURL
    case unAvailableToLoad
    case noJournalToRetrieve
    case noNewsToRetrieve
    
    var alertTitle: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL"
        case .unAvailableToLoad:
            return "페이지 로드 실패"
        case .noJournalToRetrieve:
            return "저널 로드 실패"
        case .noNewsToRetrieve:
            return "뉴스 로드 실패"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .invalidURL:
            return "유효하지 않는 URL이에요. 다시 시도해주세요."
        case .unAvailableToLoad:
            return "페이지 로드에 실패했어요. 다시 시도해주세요."
        case .noJournalToRetrieve:
            return "저장한 저널 접근에 실패했어요. 다시 시도해주세요."
        case .noNewsToRetrieve:
            return "기사를 로드할 수 없어요. 다시 시도해주세요."
        }
    }
    
}
