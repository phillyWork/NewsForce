//
//  Enum+MemoError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import Foundation

enum MemoError: Error {
    
    case noTempJournalForNews
    case noTempJournalForBookMarkedNews
    case noTempTitleForNews
    case noTempTitleForBookMarkedNews
    case noNewsToRetrieve
    case noBookMarkedNewsToRetrieve
    case noJournalToRetrieve
    case noTagToRetrieve
    case noTagForDTONews
    
    var alertTitle: String {
        switch self {
        case .noTempJournalForNews, .noTempJournalForBookMarkedNews:
            return "임시 메모 없음"
        case .noTempTitleForNews, .noTempTitleForBookMarkedNews:
            return "임시 제목 없음"
        case .noNewsToRetrieve:
            return "뉴스 링크 존재하지 않음"
        case .noBookMarkedNewsToRetrieve:
            return "저널 존재하지 않음"
        case .noJournalToRetrieve:
            return "메모 존재하지 않음"
        case .noTagToRetrieve:
            return "태그 존재하지 않음"
        case .noTagForDTONews:
            return "태그 존재하지 않음"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .noTempJournalForNews, .noTempJournalForBookMarkedNews:
            return "임시 메모가 존재하지 않아요"
        case .noTempTitleForNews, .noTempTitleForBookMarkedNews:
            return "임시 제목이 존재하지 않아요"
        case .noNewsToRetrieve:
            return "해당 뉴스 정보가 존재하지 않아요"
        case .noBookMarkedNewsToRetrieve:
            return "해당 북마크된 뉴스가 존재하지 않아요"
        case .noJournalToRetrieve:
            return "해당 저널이 존재하지 않아요"
        case .noTagToRetrieve:
            return "저장된 태그가 존재하지 않아요"
        case .noTagForDTONews:
            return "저장된 태그가 존재하지 않아요"
        }
    }
    
}
