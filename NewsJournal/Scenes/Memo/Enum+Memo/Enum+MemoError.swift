//
//  Enum+MemoError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import Foundation

enum MemoError: Error {
    
    case noTempMemoForNews
    case noTempMemoForJournal
    case noTempTitleForNews
    case noTempTitleForJournal
    case noNewsToRetrieve
    case noJournalToRetrieve
    case noMemoToRetrieve
    
    var alertTitle: String {
        switch self {
        case .noTempMemoForNews, .noTempMemoForJournal:
            return "임시 메모 없음"
        case .noTempTitleForNews, .noTempTitleForJournal:
            return "임시 제목 없음"
        case .noNewsToRetrieve:
            return "뉴스 링크 존재하지 않음"
        case .noJournalToRetrieve:
            return "저널 존재하지 않음"
        case .noMemoToRetrieve:
            return "메모 존재하지 않음"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .noTempMemoForNews, .noTempMemoForJournal:
            return "임시 메모가 존재하지 않아요"
        case .noTempTitleForNews, .noTempTitleForJournal:
            return "임시 제목이 존재하지 않아요"
        case .noNewsToRetrieve:
            return "해당 뉴스 정보가 존재하지 않아요"
        case .noJournalToRetrieve:
            return "해당 저널이 존재하지 않아요"
        case .noMemoToRetrieve:
            return "해당 메모가 존재하지 않아요"
        }
    }
    
}
