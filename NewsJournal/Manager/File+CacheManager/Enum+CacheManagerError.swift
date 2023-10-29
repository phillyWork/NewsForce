//
//  Enum+CacheManagerError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import Foundation

enum CacheManagerError: Error {
    
    case noDocumentsDirectory
    case fileDeletionFailure
    case fetchingFileFailure
    case jpegCompressionFailure
    case savingFileFailure
    case unknown
    
    var alertTitle: String {
        switch self {
        case .noDocumentsDirectory:
            return "Documents 경로 에러"
        case .fileDeletionFailure:
            return "파일 삭제 실패"
        case .fetchingFileFailure:
            return "파일 불러오기 실패"
        case .jpegCompressionFailure:
            return "파일 압축 실패"
        case .savingFileFailure:
            return "파일 저장 실패"
        case .unknown:
            return "오류 발생!"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .noDocumentsDirectory:
            return "Documents 경로를 찾을 수 없습니다."
        case .fileDeletionFailure:
            return "삭제할 수 없습니다."
        case .fetchingFileFailure:
            return "불러올 수 없습니다."
        case .jpegCompressionFailure:
            return "압축할 수 없습니다."
        case .savingFileFailure:
            return "저장할 수 없습니다."
        case .unknown:
            return "알 수 없는 오류로 실패했습니다."
        }
    }
    
}
