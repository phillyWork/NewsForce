//
//  Enum+BarButtonType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

enum BarButtonType {
    
    case selectForPDF
    case createPDFDocument
    case selectForDeletion
    case deletionConfirmation
    case cancel
    
    var buttonTitle: String {
        switch self {
        case .selectForPDF:
            return "PDF"
        case .createPDFDocument:
            return "생성하기"
        case .selectForDeletion:
            return "삭제"
        case .deletionConfirmation:
            return "확인"
        case .cancel:
            return "취소"
        }
    }
    
}
